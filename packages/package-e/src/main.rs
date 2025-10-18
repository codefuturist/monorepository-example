use colored::Colorize;
use serde_json::json;
use std::process;

// Re-export library functions
use package_e::{reverse_string, count_vowels, is_palindrome};

fn print_separator(title: &str) {
    println!("{}", "=".repeat(60));
    if !title.is_empty() {
        println!("{}", title);
        println!("{}", "=".repeat(60));
    }
}

fn main() {
    print_separator("Package E - String Manipulation v1.0.0");
    
    // Verify dependencies are loaded
    println!("\n{}", "✓ colored dependency loaded successfully".green());
    println!("{}", "✓ serde_json dependency loaded successfully".green());
    println!("{}\n", "✓ String utilities initialized".green());
    
    // Test strings
    let test_strings = vec![
        "Hello Rust",
        "racecar",
        "A man a plan a canal Panama",
        "Package E",
    ];
    
    let mut results = Vec::new();
    
    println!("{}", "String Manipulation Results:".cyan().bold());
    println!("{}", "-".repeat(60));
    
    for s in &test_strings {
        match run_tests(s) {
            Ok(result) => {
                println!("\n{}: \"{}\"", "Input".yellow(), s);
                println!("  {}: {}", "Reversed".cyan(), result.reversed);
                println!("  {}: {}", "Vowel Count".cyan(), result.vowels);
                println!("  {}: {}", "Is Palindrome".cyan(), 
                    if result.is_palindrome { 
                        "Yes".green() 
                    } else { 
                        "No".red() 
                    });
                
                results.push(json!({
                    "original": s,
                    "reversed": result.reversed,
                    "vowel_count": result.vowels,
                    "is_palindrome": result.is_palindrome
                }));
            },
            Err(e) => {
                eprintln!("{} {}", "ERROR:".red().bold(), e);
                process::exit(1);
            }
        }
    }
    
    // Output JSON
    println!("\n{}", "JSON Output:".cyan().bold());
    println!("{}", "-".repeat(60));
    match serde_json::to_string_pretty(&results) {
        Ok(json_str) => println!("{}", json_str),
        Err(e) => {
            eprintln!("{} Failed to serialize results: {}", "ERROR:".red().bold(), e);
            process::exit(1);
        }
    }
    
    println!();
    print_separator(&"Package E executed successfully!".green().bold().to_string());
    println!();
}

struct TestResult {
    reversed: String,
    vowels: usize,
    is_palindrome: bool,
}

fn run_tests(s: &str) -> Result<TestResult, String> {
    Ok(TestResult {
        reversed: reverse_string(s),
        vowels: count_vowels(s),
        is_palindrome: is_palindrome(s),
    })
}
