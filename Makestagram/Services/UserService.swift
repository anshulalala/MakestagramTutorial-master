//
//  UserService.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 6/26/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth.FIRUser

// Here we remove the networking-related code of creating a new user in our CreateUsernameViewController and place it inside our service struct. The service struct will act as an intermediary for communicating between our app and Firebase.
struct UserService {
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs: [String : Any] = ["username": username,
                                         "follower_count": 0,
                                         "following_count" : 0,
                                         "post_count" : 0]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            completion(user)
        })
    }
    
    // fetch and return all of our posts from Firebase from a given user
    // check whether each of our posts is liked by the current user. We use dispatch groups to wait for all of the asynchronous code to complete before calling our completion handler on the main thread. Now each post that is returned with our posts(for:completion:) service method will have data on whether the current user has liked it or not.
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        let ref = DatabaseReference.toLocation(.posts(uid: user.uid))
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] =
                snapshot
                    .reversed()
                    .flatMap {
                        guard let post = Post(snapshot: $0)
                            else { return nil }
                        
                        dispatchGroup.enter()
                        
                        LikeService.isPostLiked(post) { (isLiked) in
                            post.isLiked = isLiked
                            
                            dispatchGroup.leave()
                        }
                        
                        return post
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
            })
        })
    }

    // fetch all users on the app and display them
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        // 1 - Create a DatabaseReference to read all users from the database.
        let ref = Database.database().reference().child("users")
        
        // 2 - Read the users node from the database.
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            // 3 - Take the snapshot and perform a few transformations. First, we convert all of the child DataSnapshot into User using our failable initializer. Next we filter out the current user object from the User array.
            let users =
                snapshot
                    .flatMap(User.init)
                    .filter { $0.uid != currentUser.uid }
            
            // 4 - Create a new DispatchGroup so that we can be notified when all asynchronous tasks are finished executing. We'll use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read.
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                // 5 - Make a request for each individual user to determine if the user is being followed by the current user.
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            
            // 6 - Run the completion block after all follow relationship data has returned.
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }

    
    // Whenever a user creates a new post, write the post to each of the user's follower's timelines
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
    static func timeline(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([Post]) -> Void) {
        let currentUser = User.current
        
        let ref = Database.database().reference().child("timeline").child(currentUser.uid)
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts.reversed())
            })
        })
    }
   
    // service method to retrieve data to provide content for a given user's profile. We'll return the user object and all of the user's posts from Firebase.
    static func observeProfile(for user: User, completion: @escaping (DatabaseReference, User?, [Post]) -> Void) -> DatabaseHandle {
        // Create a reference to the location we want to read the user object from.
        let userRef = Database.database().reference().child("users").child(user.uid)
        
        // Observer the DatabaseReference to retrieve the user object.
        return userRef.observe(.value, with: { snapshot in
            // Check that the data returned is a valid user. If not, return an empty completion block.
            guard let user = User(snapshot: snapshot) else {
                return completion(userRef, nil, [])
            }
            
            // Retrieve all posts for the respective user.
            posts(for: user, completion: { posts in
                // Return the completion block with a reference to the DatabaseReference, user, and posts if successful.
                completion(userRef, user, posts)
            })
        })
    }
    
    
}
