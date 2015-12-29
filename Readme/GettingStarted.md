#Getting Started with Swift Flow

Swift Flow provides the infrastructure for `Store`s, `Action`s and `Reducer`s to enable a unidirectional data flow as shown below. 

![](Assets/swift_flow_detail.png)

The following steps will describe how to set up the individual components for your Swift Flow app.

#State

The application state is defined in a single data structure which should be a struct. This struct can have other structs as members, that allows you to add different sub-states as your app grows. 

The state struct should store your entire application state, that includes the UI state, the navigation state and the state of your model layer. 

Here's an example of a state struct as defined in the [Counter Example](https://github.com/Swift-Flow/CounterExample):

```swift
struct AppState: StateType, HasNavigationState {
    var counter: Int = 0
    var navigationState = NavigationState()
}
```

There are multiple things to note:

1. Your app state struct needs to conform to the `StateType` protocol, currently this is just a marker protocol, but we will likely add requirements (such as the ability to [serialize the state](https://github.com/Swift-Flow/Swift-Flow/issues/3)) before v1.0.
2. If you are including `SwiftRouter` in your project, your app state needs to conform to the `HasNavigationState` protocol. This means you need to add a property called `navigationState` to your state struct. This is the sub-state the router will use to store the current route. 

##Viewing the State Through a Protocol

Protocols are extremely useful for working with this framework. As you can see in the example above, `SwiftRouter` can work with any app state that you define, as long as it conforms to the `HasNavigationState` protocol. The router will only ever access your app state through this protocol - this also means it won't ever see and depend upon any other state that you store within your state struct.

**You should use this approach as much as possible in your app.** Swift Flow provides some features that make this approach even easier to use. Let's say you want to expand the state above by a simple authentication state. You would do this by first defining a new struct for this sub-state:

```swift
struct AuthenticationState {
	var userAuthenticated = false
}
```

*Additionally,* you would define a protocol that requires your app state to include the `AuthenticationState`:

```swift
protocol HasAuthenticationState {
	var authenticationState: AuthenticationState
}
```
Now you can extend your state using this protocol:

```swift
struct AppState: StateType, HasNavigationState, HasAuthenticationState {
    var counter: Int = 0
    var navigationState = NavigationState()
    var authenticationState = AuthenticationState()
}
```

If you now add a view (or any other subscriber) that is only interested in this particular substate, you should express this within your `newState` method (that is the callback for all subscribers in Swift Flow).

You would implement the `newState` method as following:

```swift
    func newState(state: HasAuthenicationState) {
        loggedInLabel.text = "\(state.authenticationState.userAuthenticated)"
    }
```
Swift Flow will infer the type that you have required and will automatically cast your app state to that type - this means the particular subscriber will only see the required substate, not any other state in your app. **This approach will help you reduce dependencies on state that should be irrelevant to your component**.

Currently your method is not called if the state cannot be casted into the required type - [we're considering changing this into a `fatalError` as it will make debugging easier](). 

##Derived State

Note that you don't need to store derived state inside of your app state. E.g. instead of storing a `UIImage` you should store a image URL that can be used to fetch the image from a cache or via a download. The app state should store all the information that uniquely identifies the current state and allows it to be reconstructed, but none that can be easily derived. 


#Actions

Swift Flow provides the `Action` type to create actions that describe state changes. It has the following structure:

```swift
struct Action : ActionType {
	let type: String
   	let payload: [String : AnyObject]?
}
```
This `Action` type is serializable, which is imported for storing past actions to disk and enabling time traveling and hot reloading. 

For simple actions you can use this type directly; for actions with a complex payload you should make use of Swift's rich type system and create separate type. This type needs to be convertible into plain `Action`s.

##Using Plain Actions

The [Counter Example App](https://github.com/Swift-Flow/CounterExample) makes use of plain actions that don't carry any payload. They are simply initialized with a string constant:

```swift
    @IBAction func increaseButtonTapped(sender: UIButton) {
        mainStore.dispatch(
            Action(CounterActionIncrease)
        )
    }
```

Within your reducer you switch over the `type` string of this plain action to identify the type and perform a state change:

```swift
struct CounterReducer: Reducer {

    func handleAction(var state: AppState, action: Action) -> AppState {
        switch action.type {
        case CounterActionIncrease:
            state.counter += 1
        case CounterActionDecrease:
            state.counter -= 1
        default:
            break
        }

        return state
    }

}
```
This approach works best with simple actions, with no or very simple payloads. For more complex actions you should use a typed action.

##Using Typed Actions

Here's an example from the Meet App that shows you how to define a custom, typed action:

```swift 
struct CreateContactFromEmail {
    static let type = "CreateContactFromEmail"
    let email: String

    init(_ email: String) {
        self.email = email
    }
}

extension CreateContactFromEmail: ActionConvertible, ActionType {

    init(_ action: Action) {
    	if (action.type != CreateContactFromEmail.type) {
    		fatalError("Typed Action cannot be initialized with plain Action of wrong type!")
    	}
        self.email = action.payload!["email"] as! String
    }

    func toAction() -> Action {
        return Action(type: CreateContactFromEmail.type, payload: ["email": email])
    }
}
```
The `CreateContactFromEmail` struct contains a type string that identifies this action (this preserves the type upon serialization and deserialization) and a payload, in this case an email address. 

In the extension you can see boilerplate code that allows this typed action to be initialized with a plain action and that allows us to convert it into a plain action. [This code will mostly be auto-generated in future, since it is one of the painpoints of working with this framework right now.](https://github.com/Swift-Flow/Swift-Flow/issues/2)

###Dispatching a Typed Action

The `Store` will accept your typed action directly, as soon as it conforms to the `ActionType` protocol. You can dispatch a typed action the same way as dispatching a plain action:

```swift
store.dispatch(CreateContactFromEmail("Benjamin.Encz@gmail.com"))
```

###Using Typed Actions in a Reducer

In the `handleAction` method of your reducers you will always receive plain `Action`s. This ensure that your reducer works with serialized actions and therefore supports time-traveling and hot-reloading. If your typed action conforms to `ActionConvertible` then it provides a convenience initializer that allows you to easily create a typed action from an untyped one. You should do this as part of your type checking code in the reducers, e.g.:

```swift
    func handleAction(state: HasDataState, action: Action) -> HasDataState {
        switch action.type {
        case CreateContactFromEmail.type:
            return createContact(state, email: CreateContactFromEmail(action).email)
			...
        }
    }
    
    func createContact(var state: HasDataState, email: String) -> HasDataState {
        let newContactID = state.dataState.contacts.count + 1
        let newContact = Contact(identifier: newContactID, emailAddress: email)
        state.dataState.contacts.append(newContact)

        return state
    }
```

We create a typed action from the plain action and pass it on to a method of the reducer. This way the method has access to the types defined as part of our `CreateContactFromEmail` method.

#Reducers

This is the only place where you should modify application state! Reducers, just as `StoreSubscribers` can define the particular slice of the app state that they are interested in by changing the type in their `handleAction` method. Here's an example of a part of a reducer in an app built with Swift Flow:

```swift
struct DataMutationReducer: Reducer {

    func handleAction(state: HasDataState, action: Action) -> HasDataState {
        switch action.type {
        case CreateContactFromEmail.type:
            return createContact(state, email: CreateContactFromEmail(action).email)
        case CreateContactWithTwitterUser.type:
            return createContact(state, twitterUser: CreateContactWithTwitterUser(action).twitterUser)
        case DeleteContact.type:
            return deleteContact(state, identifier: DeleteContact(action).contactID)
        case SetContacts.type:
            return setContacts(state, contacts: SetContacts(action).contacts)
        default:
            return state
        }
    }

    func createContact(var state: HasDataState, email: String) -> HasDataState {
        let newContactID = state.dataState.contacts.count + 1
        let newContact = Contact(identifier: newContactID, emailAddress: email)
        state.dataState.contacts.append(newContact)

        return state
    }

    func createContact(var state: HasDataState, twitterUser: TwitterUser) -> HasDataState {
        let newContactID = state.dataState.contacts.count + 1
        let newContact = Contact(identifier: newContactID, twitterHandle: twitterUser.username)
        state.dataState.contacts.append(newContact)

        return state
    }
```

You typically switch over the types in `handleAction`, then instantiate typed actions from plain actions and finally call a method that implements the actual state mutation.

#Middleware

Swift Flow supports middleware in the same way as Redux does, [you can read this great documentation on Redux middleware to get started](http://rackt.org/redux/docs/advanced/Middleware.html).

Let's take a look at a quick example that shows how Swift Flow supports Redux style middleware.

The simplest example of a middleware, is one that prints all actions to the console. Here's how you can implement it:

```
let loggingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in
			// perform middleware logic
            print(action)
            
			// call next middleware
            return next(action)
        }
    }
}
```
You can define which middleware you would like to use when creating your store:

```
MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [loggingMiddleware, secondMiddleware])
``` 
