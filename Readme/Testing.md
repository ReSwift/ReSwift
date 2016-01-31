# Checking out Source Code and Running Tests

Due to an [issue in Nimble](https://github.com/Quick/Nimble/issues/213) at the moment, tvOS tests will fail if building Nimble / Quick from source. You can however install Nimble & Quick from binaries then rebuild OSX & iOS only. After checkout, run the following from the terminal:

```bash
carthage bootstrap && carthage bootstrap --no-use-binaries --platform ios,osx
```
