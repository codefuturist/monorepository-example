package com.example.packageh;

import com.diogonunes.jcolor.Ansi;
import com.diogonunes.jcolor.Attribute;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.util.Arrays;
import java.util.List;

/**
 * Main entry point for package-h CLI application.
 */
public class Main {

    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    public static void main(String[] args) {
        printSeparator("Package H - Collection Utilities v1.0.0");

        try {
            // Verify dependencies are loaded
            System.out.println(Ansi.colorize("\n✓ JColor dependency loaded successfully",
                Attribute.GREEN_TEXT()));
            System.out.println(Ansi.colorize("✓ Gson dependency loaded successfully",
                Attribute.GREEN_TEXT()));
            System.out.println(Ansi.colorize("✓ Collection utilities initialized\n",
                Attribute.GREEN_TEXT()));

            runTests();

            System.out.println();
            System.out.println(Ansi.colorize("=" + repeat("=", 59), Attribute.GREEN_TEXT()));
            System.out.println(Ansi.colorize("Package H executed successfully!", Attribute.GREEN_TEXT()));
            System.out.println(Ansi.colorize("=" + repeat("=", 59) + "\n", Attribute.GREEN_TEXT()));

        } catch (IllegalArgumentException e) {
            System.err.println(Ansi.colorize("\nERROR: Invalid argument - " + e.getMessage(),
                Attribute.RED_TEXT(), Attribute.BOLD()));
            System.exit(1);
        } catch (Exception e) {
            System.err.println(Ansi.colorize("\nFATAL ERROR: " + e.getMessage(),
                Attribute.RED_TEXT(), Attribute.BOLD()));
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void runTests() {
        JsonArray results = new JsonArray();

        System.out.println(Ansi.colorize("Collection Utility Demonstrations:",
            Attribute.CYAN_TEXT(), Attribute.BOLD()));
        System.out.println(repeat("-", 60));

        // Test removeDuplicates
        System.out.println(Ansi.colorize("\nRemove Duplicates Test:", Attribute.YELLOW_TEXT()));
        List<Integer> numbersWithDupes = Arrays.asList(1, 2, 2, 3, 3, 3, 4, 5, 5);
        System.out.println("  Original: " + numbersWithDupes);
        List<Integer> unique = CollectionUtils.removeDuplicates(numbersWithDupes);
        System.out.println(Ansi.colorize("  Result: " + unique, Attribute.CYAN_TEXT()));

        JsonObject test1 = new JsonObject();
        test1.addProperty("operation", "removeDuplicates");
        test1.add("input", gson.toJsonTree(numbersWithDupes));
        test1.add("result", gson.toJsonTree(unique));
        results.add(test1);

        // Test chunk
        System.out.println(Ansi.colorize("\nChunk Test:", Attribute.YELLOW_TEXT()));
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9);
        System.out.println("  Original: " + numbers);
        List<List<Integer>> chunks = CollectionUtils.chunk(numbers, 3);
        System.out.println(Ansi.colorize("  Chunked (size 3): " + chunks, Attribute.CYAN_TEXT()));

        JsonObject test2 = new JsonObject();
        test2.addProperty("operation", "chunk");
        test2.add("input", gson.toJsonTree(numbers));
        test2.addProperty("chunkSize", 3);
        test2.add("result", gson.toJsonTree(chunks));
        results.add(test2);

        // Test mostFrequent
        System.out.println(Ansi.colorize("\nMost Frequent Element Test:", Attribute.YELLOW_TEXT()));
        List<String> words = Arrays.asList("apple", "banana", "apple", "cherry", "apple", "banana");
        System.out.println("  Original: " + words);
        String mostFreq = CollectionUtils.mostFrequent(words);
        System.out.println(Ansi.colorize("  Most frequent: " + mostFreq, Attribute.CYAN_TEXT()));

        JsonObject test3 = new JsonObject();
        test3.addProperty("operation", "mostFrequent");
        test3.add("input", gson.toJsonTree(words));
        test3.addProperty("result", mostFreq);
        results.add(test3);

        // Test interleave
        System.out.println(Ansi.colorize("\nInterleave Test:", Attribute.YELLOW_TEXT()));
        List<Integer> odds = Arrays.asList(1, 3, 5, 7);
        List<Integer> evens = Arrays.asList(2, 4, 6, 8);
        System.out.println("  List 1: " + odds);
        System.out.println("  List 2: " + evens);
        List<Integer> interleaved = CollectionUtils.interleave(odds, evens);
        System.out.println(Ansi.colorize("  Interleaved: " + interleaved, Attribute.CYAN_TEXT()));

        JsonObject test4 = new JsonObject();
        test4.addProperty("operation", "interleave");
        test4.add("list1", gson.toJsonTree(odds));
        test4.add("list2", gson.toJsonTree(evens));
        test4.add("result", gson.toJsonTree(interleaved));
        results.add(test4);

        // Error handling test
        System.out.println(Ansi.colorize("\nError Handling Test:", Attribute.YELLOW_TEXT()));
        try {
            CollectionUtils.chunk(Arrays.asList(1, 2, 3), 0);
            System.out.println(Ansi.colorize("  ✗ Should have thrown exception for invalid chunk size",
                Attribute.RED_TEXT()));
        } catch (IllegalArgumentException e) {
            System.out.println(Ansi.colorize("  ✓ Invalid chunk size error caught: " + e.getMessage(),
                Attribute.GREEN_TEXT()));
        }

        // Print JSON output
        System.out.println(Ansi.colorize("\nJSON Output:", Attribute.CYAN_TEXT(), Attribute.BOLD()));
        System.out.println(repeat("-", 60));
        System.out.println(gson.toJson(results));
    }

    private static void printSeparator(String title) {
        System.out.println(repeat("=", 60));
        if (!title.isEmpty()) {
            System.out.println(title);
            System.out.println(repeat("=", 60));
        }
    }

    private static String repeat(String s, int count) {
        return new String(new char[count]).replace("\0", s);
    }
}
