# Package H - Java Collection Utilities

A collection of utility functions for common Java collection operations, designed for the monorepository-example project.

## Features

- **removeDuplicates**: Remove duplicate elements from a list while preserving insertion order
- **chunk**: Partition a list into smaller chunks of a specified size
- **mostFrequent**: Find the most frequently occurring element in a list
- **interleave**: Combine two lists by alternating their elements

## Requirements

- Java 17 or higher
- Maven 3.6 or higher

## Building

```bash
cd packages/package-h
mvn clean compile
```

## Testing

Run all tests:

```bash
mvn test
```

Run tests with verbose output:

```bash
mvn test -X
```

## Usage Examples

### Remove Duplicates

```java
import com.example.packageh.CollectionUtils;
import java.util.Arrays;
import java.util.List;

List<Integer> numbers = Arrays.asList(1, 2, 2, 3, 3, 3, 4);
List<Integer> unique = CollectionUtils.removeDuplicates(numbers);
// Result: [1, 2, 3, 4]
```

### Chunk a List

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7);
List<List<Integer>> chunks = CollectionUtils.chunk(numbers, 3);
// Result: [[1, 2, 3], [4, 5, 6], [7]]
```

### Find Most Frequent Element

```java
List<String> words = Arrays.asList("apple", "banana", "apple", "cherry", "apple");
String mostCommon = CollectionUtils.mostFrequent(words);
// Result: "apple"
```

### Interleave Two Lists

```java
List<Integer> odds = Arrays.asList(1, 3, 5);
List<Integer> evens = Arrays.asList(2, 4, 6);
List<Integer> combined = CollectionUtils.interleave(odds, evens);
// Result: [1, 2, 3, 4, 5, 6]
```

## Packaging

Create a JAR file:

```bash
mvn package
```

The JAR will be created in `target/package-h-1.0.0.jar`.

## Release Process

This package follows Git Flow and uses tag-based releases:

1. **Create a release branch:**
   ```bash
   git flow release start package-h-1.0.0
   ```

2. **Finish the release:**
   ```bash
   git flow release finish package-h-1.0.0
   ```

3. **Push the tag to trigger the release:**
   ```bash
   git push origin package-h@v1.0.0
   ```

4. **Monitor the GitHub Actions workflow:**
   ```bash
   gh workflow view "Java Package Release"
   gh run list --workflow=java-release.yml
   ```

The GitHub Actions workflow will:
- Build the project on Ubuntu, macOS, and Windows
- Test with Java 17 and 21
- Create a JAR artifact
- Publish a GitHub release with the JAR attached

## License

Part of the monorepository-example project.
