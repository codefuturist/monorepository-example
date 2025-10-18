/// Reverse a string
/// 
/// # Examples
/// 
/// ```
/// use package_e::reverse_string;
/// 
/// let result = reverse_string("hello");
/// assert_eq!(result, "olleh");
/// ```
pub fn reverse_string(s: &str) -> String {
    s.chars().rev().collect()
}

/// Count vowels in a string
/// 
/// # Examples
/// 
/// ```
/// use package_e::count_vowels;
/// 
/// let count = count_vowels("hello world");
/// assert_eq!(count, 3);
/// ```
pub fn count_vowels(s: &str) -> usize {
    s.chars()
        .filter(|c| matches!(c.to_ascii_lowercase(), 'a' | 'e' | 'i' | 'o' | 'u'))
        .count()
}

/// Check if a string is a palindrome
/// 
/// # Examples
/// 
/// ```
/// use package_e::is_palindrome;
/// 
/// assert_eq!(is_palindrome("racecar"), true);
/// assert_eq!(is_palindrome("hello"), false);
/// ```
pub fn is_palindrome(s: &str) -> bool {
    let cleaned: String = s.chars()
        .filter(|c| c.is_alphanumeric())
        .map(|c| c.to_ascii_lowercase())
        .collect();
    
    cleaned == cleaned.chars().rev().collect::<String>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_reverse_string() {
        assert_eq!(reverse_string("hello"), "olleh");
        assert_eq!(reverse_string("rust"), "tsur");
        assert_eq!(reverse_string(""), "");
    }

    #[test]
    fn test_count_vowels() {
        assert_eq!(count_vowels("hello"), 2);
        assert_eq!(count_vowels("aeiou"), 5);
        assert_eq!(count_vowels("xyz"), 0);
        assert_eq!(count_vowels("HELLO"), 2);
    }

    #[test]
    fn test_is_palindrome() {
        assert_eq!(is_palindrome("racecar"), true);
        assert_eq!(is_palindrome("A man a plan a canal Panama"), true);
        assert_eq!(is_palindrome("hello"), false);
        assert_eq!(is_palindrome(""), true);
    }
}
