Actions are used to express intended state changes. Actions don't contain functions, instead they provide information about the intended state change, e.g. which user should be deleted.

In your ReSwift app you will define actions for every possible state change that can happen.

Reducers handle these actions and implement state changes based on the information they provide.

All actions in ReSwift conform to the `Action` protocol, which currently is just a marker protocol.

You can either provide custom types as actions, or you can use the built in `StandardAction`.
