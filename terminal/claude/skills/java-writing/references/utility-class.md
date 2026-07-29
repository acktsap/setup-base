# Utility Classes

- Use a utility class only for stateless operations or constants that do not have a more natural owning type.
- Declare it `abstract` with a private constructor, and never subclass it.
- Make every member static and keep no mutable static state.

```java
public abstract class ExampleUtils {
    private ExampleUtils() {
    }
}
```
