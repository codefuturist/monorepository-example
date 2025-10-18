package com.example.packageh;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Collection utility functions for common operations.
 */
public class CollectionUtils {

    /**
     * Removes duplicate elements from a list while preserving order.
     *
     * @param <T>  the type of elements in the list
     * @param list the input list
     * @return a new list with duplicates removed
     */
    public static <T> List<T> removeDuplicates(List<T> list) {
        if (list == null) {
            return new ArrayList<>();
        }
        return list.stream()
                .distinct()
                .collect(Collectors.toList());
    }

    /**
     * Partitions a list into chunks of a specified size.
     *
     * @param <T>  the type of elements in the list
     * @param list the input list
     * @param size the chunk size
     * @return a list of chunks
     * @throws IllegalArgumentException if size is less than 1
     */
    public static <T> List<List<T>> chunk(List<T> list, int size) {
        if (size < 1) {
            throw new IllegalArgumentException("Chunk size must be at least 1");
        }
        if (list == null || list.isEmpty()) {
            return new ArrayList<>();
        }

        List<List<T>> chunks = new ArrayList<>();
        for (int i = 0; i < list.size(); i += size) {
            chunks.add(new ArrayList<>(
                    list.subList(i, Math.min(list.size(), i + size))
            ));
        }
        return chunks;
    }

    /**
     * Finds the most frequent element in a list.
     *
     * @param <T>  the type of elements in the list
     * @param list the input list
     * @return the most frequent element, or null if the list is empty
     */
    public static <T> T mostFrequent(List<T> list) {
        if (list == null || list.isEmpty()) {
            return null;
        }

        Map<T, Long> frequencies = list.stream()
                .collect(Collectors.groupingBy(
                        e -> e,
                        Collectors.counting()
                ));

        return frequencies.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(null);
    }

    /**
     * Interleaves two lists, alternating elements from each.
     *
     * @param <T>   the type of elements in the lists
     * @param list1 the first list
     * @param list2 the second list
     * @return a new list with interleaved elements
     */
    public static <T> List<T> interleave(List<T> list1, List<T> list2) {
        if (list1 == null) list1 = new ArrayList<>();
        if (list2 == null) list2 = new ArrayList<>();

        List<T> result = new ArrayList<>();
        int maxSize = Math.max(list1.size(), list2.size());

        for (int i = 0; i < maxSize; i++) {
            if (i < list1.size()) {
                result.add(list1.get(i));
            }
            if (i < list2.size()) {
                result.add(list2.get(i));
            }
        }

        return result;
    }
}
