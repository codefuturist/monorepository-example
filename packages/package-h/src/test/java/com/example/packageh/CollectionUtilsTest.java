package com.example.packageh;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("CollectionUtils Tests")
class CollectionUtilsTest {

    @Test
    @DisplayName("removeDuplicates should handle null input")
    void testRemoveDuplicatesNull() {
        List<Integer> result = CollectionUtils.removeDuplicates(null);
        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("removeDuplicates should remove duplicate elements")
    void testRemoveDuplicates() {
        List<Integer> input = Arrays.asList(1, 2, 2, 3, 3, 3, 4);
        List<Integer> expected = Arrays.asList(1, 2, 3, 4);
        List<Integer> result = CollectionUtils.removeDuplicates(input);
        assertEquals(expected, result);
    }

    @Test
    @DisplayName("removeDuplicates should preserve order")
    void testRemoveDuplicatesPreservesOrder() {
        List<String> input = Arrays.asList("apple", "banana", "apple", "cherry", "banana");
        List<String> expected = Arrays.asList("apple", "banana", "cherry");
        List<String> result = CollectionUtils.removeDuplicates(input);
        assertEquals(expected, result);
    }

    @Test
    @DisplayName("chunk should throw exception for size < 1")
    void testChunkInvalidSize() {
        List<Integer> input = Arrays.asList(1, 2, 3);
        assertThrows(IllegalArgumentException.class, () -> 
            CollectionUtils.chunk(input, 0)
        );
        assertThrows(IllegalArgumentException.class, () -> 
            CollectionUtils.chunk(input, -1)
        );
    }

    @Test
    @DisplayName("chunk should handle null and empty lists")
    void testChunkEmptyList() {
        List<List<Integer>> result = CollectionUtils.chunk(null, 2);
        assertNotNull(result);
        assertTrue(result.isEmpty());

        result = CollectionUtils.chunk(new ArrayList<>(), 2);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("chunk should partition list correctly")
    void testChunk() {
        List<Integer> input = Arrays.asList(1, 2, 3, 4, 5, 6, 7);
        List<List<Integer>> result = CollectionUtils.chunk(input, 3);
        
        assertEquals(3, result.size());
        assertEquals(Arrays.asList(1, 2, 3), result.get(0));
        assertEquals(Arrays.asList(4, 5, 6), result.get(1));
        assertEquals(Arrays.asList(7), result.get(2));
    }

    @Test
    @DisplayName("mostFrequent should return null for empty list")
    void testMostFrequentEmpty() {
        assertNull(CollectionUtils.mostFrequent(null));
        assertNull(CollectionUtils.mostFrequent(new ArrayList<>()));
    }

    @Test
    @DisplayName("mostFrequent should find most frequent element")
    void testMostFrequent() {
        List<String> input = Arrays.asList("apple", "banana", "apple", "cherry", "apple", "banana");
        String result = CollectionUtils.mostFrequent(input);
        assertEquals("apple", result);
    }

    @Test
    @DisplayName("mostFrequent should handle single element")
    void testMostFrequentSingleElement() {
        List<Integer> input = Arrays.asList(42);
        Integer result = CollectionUtils.mostFrequent(input);
        assertEquals(42, result);
    }

    @Test
    @DisplayName("interleave should handle null inputs")
    void testInterleaveNull() {
        List<Integer> list1 = Arrays.asList(1, 2, 3);
        List<Integer> result = CollectionUtils.interleave(list1, null);
        assertEquals(Arrays.asList(1, 2, 3), result);

        result = CollectionUtils.interleave(null, list1);
        assertEquals(Arrays.asList(1, 2, 3), result);

        result = CollectionUtils.interleave(null, null);
        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("interleave should alternate elements from both lists")
    void testInterleave() {
        List<Integer> list1 = Arrays.asList(1, 3, 5);
        List<Integer> list2 = Arrays.asList(2, 4, 6);
        List<Integer> result = CollectionUtils.interleave(list1, list2);
        assertEquals(Arrays.asList(1, 2, 3, 4, 5, 6), result);
    }

    @Test
    @DisplayName("interleave should handle lists of different lengths")
    void testInterleaveUnequalLengths() {
        List<String> list1 = Arrays.asList("a", "b");
        List<String> list2 = Arrays.asList("1", "2", "3", "4");
        List<String> result = CollectionUtils.interleave(list1, list2);
        assertEquals(Arrays.asList("a", "1", "b", "2", "3", "4"), result);
    }
}
