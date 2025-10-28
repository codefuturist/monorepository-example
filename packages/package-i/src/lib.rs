use colored::*;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Data structure for user information
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct User {
    pub id: u32,
    pub name: String,
    pub email: String,
    pub active: bool,
}

/// Calculate average of numbers
pub fn calculate_average(numbers: &[f64]) -> Option<f64> {
    if numbers.is_empty() {
        return None;
    }
    let sum: f64 = numbers.iter().sum();
    Some(sum / numbers.len() as f64)
}

/// Find median of numbers
pub fn find_median(numbers: &mut [f64]) -> Option<f64> {
    if numbers.is_empty() {
        return None;
    }

    numbers.sort_by(|a, b| a.partial_cmp(b).unwrap());
    let len = numbers.len();

    if len % 2 == 0 {
        Some((numbers[len / 2 - 1] + numbers[len / 2]) / 2.0)
    } else {
        Some(numbers[len / 2])
    }
}

/// Count word frequency in text
pub fn word_frequency(text: &str) -> HashMap<String, usize> {
    let mut freq = HashMap::new();

    for word in text.split_whitespace() {
        let word = word.to_lowercase().trim_matches(|c: char| !c.is_alphanumeric()).to_string();
        if !word.is_empty() {
            *freq.entry(word).or_insert(0) += 1;
        }
    }

    freq
}

/// Validate email format (simple check)
pub fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.') && email.len() > 5
}

/// Convert user to JSON
pub fn user_to_json(user: &User) -> Result<String, serde_json::Error> {
    serde_json::to_string_pretty(user)
}

/// Parse JSON to user
pub fn json_to_user(json: &str) -> Result<User, serde_json::Error> {
    serde_json::from_str(json)
}

/// Pretty print user with colors
pub fn print_user(user: &User) {
    println!("{}", "User Information:".bright_cyan().bold());
    println!("  {}: {}", "ID".yellow(), user.id.to_string().green());
    println!("  {}: {}", "Name".yellow(), user.name.bright_white());
    println!("  {}: {}", "Email".yellow(), user.email.bright_white());
    println!("  {}: {}",
        "Status".yellow(),
        if user.active { "Active".green() } else { "Inactive".red() }
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_average() {
        let numbers = vec![1.0, 2.0, 3.0, 4.0, 5.0];
        assert_eq!(calculate_average(&numbers), Some(3.0));

        let empty: Vec<f64> = vec![];
        assert_eq!(calculate_average(&empty), None);
    }

    #[test]
    fn test_find_median() {
        let mut numbers = vec![3.0, 1.0, 5.0, 2.0, 4.0];
        assert_eq!(find_median(&mut numbers), Some(3.0));

        let mut even = vec![1.0, 2.0, 3.0, 4.0];
        assert_eq!(find_median(&mut even), Some(2.5));
    }

    #[test]
    fn test_word_frequency() {
        let text = "hello world hello rust world";
        let freq = word_frequency(text);
        assert_eq!(freq.get("hello"), Some(&2));
        assert_eq!(freq.get("world"), Some(&2));
        assert_eq!(freq.get("rust"), Some(&1));
    }

    #[test]
    fn test_validate_email() {
        assert!(validate_email("user@example.com"));
        assert!(!validate_email("invalid"));
        assert!(!validate_email("@.com"));
    }

    #[test]
    fn test_user_serialization() {
        let user = User {
            id: 1,
            name: "John Doe".to_string(),
            email: "john@example.com".to_string(),
            active: true,
        };

        let json = user_to_json(&user).unwrap();
        let parsed = json_to_user(&json).unwrap();

        assert_eq!(user.id, parsed.id);
        assert_eq!(user.name, parsed.name);
        assert_eq!(user.email, parsed.email);
        assert_eq!(user.active, parsed.active);
    }
}
