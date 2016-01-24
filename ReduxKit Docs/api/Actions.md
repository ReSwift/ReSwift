## Plain Actions

ReduxKit only defines a minimal protocol that `Action` types must conform to. Action types can be enums, structs or classes. Examples:

```swift
// A simple enum with three actions
enum CountAction: Action {
	case Increment
	case Decrement
	case Set(payload: Int)
}

// The IncrementAction as a struct:
struct IncrementAction: Action {
	let payload: Int
}

// Or even a class
class IncrementActionClass: Action {
	let payload: Int
	init(payload: Int) {
		self.payload = payload
	}
}
```

## Flux Standard Actions

[Flux Standard Actions](https://github.com/acdlite/flux-standard-action) are also implemented for applications that require consistent Actions. Flux Standard Actions allows for a lot of flexibility while still maintaining a standard pattern. Example:

```swift
struct IncrementAction: StandardAction {
    let meta: Any?
    let error: Bool
    let rawPayload: Int

    init(payload: Int? = nil, meta: Any? = nil, error: Bool = false) {
        self.rawPayload = payload ?? 1
        self.meta = meta
        self.error = error
    }
}
```
