use clap::{Parser, Subcommand};
use colored::*;
use package_i::*;
use std::process;

#[derive(Parser)]
#[command(name = "package-i")]
#[command(author, version, about = "Rust CLI utilities for data processing", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Calculate statistics (average, median) from numbers
    Stats {
        /// Numbers to process
        #[arg(short, long, value_delimiter = ',')]
        numbers: Vec<f64>,
    },

    /// Analyze word frequency in text
    Frequency {
        /// Text to analyze
        #[arg(short, long)]
        text: String,
    },

    /// Validate email address
    Email {
        /// Email address to validate
        #[arg(short, long)]
        address: String,
    },

    /// Create and display a user
    User {
        /// User ID
        #[arg(short, long)]
        id: u32,

        /// User name
        #[arg(short, long)]
        name: String,

        /// User email
        #[arg(short, long)]
        email: String,

        /// User is active
        #[arg(short, long, default_value = "true")]
        active: bool,
    },

    /// Run demo with all features
    Demo,
}

fn main() {
    // Check dependencies
    if let Err(e) = check_dependencies() {
        eprintln!("{} {}", "Error:".red().bold(), e);
        process::exit(1);
    }

    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Stats { numbers }) => {
            if numbers.is_empty() {
                eprintln!("{} No numbers provided", "Error:".red().bold());
                process::exit(1);
            }

            println!("{}", "Statistical Analysis".bright_cyan().bold());
            println!("{}", "=".repeat(50).cyan());

            if let Some(avg) = calculate_average(numbers) {
                println!("  {}: {}", "Average".yellow(), format!("{:.2}", avg).green());
            }

            let mut nums = numbers.clone();
            if let Some(median) = find_median(&mut nums) {
                println!("  {}: {}", "Median".yellow(), format!("{:.2}", median).green());
            }

            let min = numbers.iter().fold(f64::INFINITY, |a, &b| a.min(b));
            let max = numbers.iter().fold(f64::NEG_INFINITY, |a, &b| a.max(b));

            println!("  {}: {}", "Min".yellow(), format!("{:.2}", min).green());
            println!("  {}: {}", "Max".yellow(), format!("{:.2}", max).green());
            println!("  {}: {}", "Count".yellow(), numbers.len().to_string().green());
        }

        Some(Commands::Frequency { text }) => {
            println!("{}", "Word Frequency Analysis".bright_cyan().bold());
            println!("{}", "=".repeat(50).cyan());

            let freq = word_frequency(text);
            let mut words: Vec<_> = freq.iter().collect();
            words.sort_by(|a, b| b.1.cmp(a.1));

            for (word, count) in words.iter().take(10) {
                println!("  {}: {}", word.yellow(), count.to_string().green());
            }
        }

        Some(Commands::Email { address }) => {
            println!("{}", "Email Validation".bright_cyan().bold());
            println!("{}", "=".repeat(50).cyan());
            println!("  {}: {}", "Email".yellow(), address.bright_white());

            if validate_email(address) {
                println!("  {}: {}", "Status".yellow(), "Valid ✓".green().bold());
            } else {
                println!("  {}: {}", "Status".yellow(), "Invalid ✗".red().bold());
            }
        }

        Some(Commands::User { id, name, email, active }) => {
            let user = User {
                id: *id,
                name: name.clone(),
                email: email.clone(),
                active: *active,
            };

            print_user(&user);

            println!("\n{}", "JSON Representation:".bright_cyan().bold());
            if let Ok(json) = user_to_json(&user) {
                println!("{}", json.bright_black());
            }
        }

        Some(Commands::Demo) | None => {
            run_demo();
        }
    }
}

fn check_dependencies() -> Result<(), String> {
    // Check if colored output is available
    let test = "test".green();
    if test.to_string().is_empty() {
        return Err("Colored output dependency is not working".to_string());
    }

    // Check if JSON serialization works
    let test_user = User {
        id: 1,
        name: "Test".to_string(),
        email: "test@example.com".to_string(),
        active: true,
    };

    user_to_json(&test_user).map_err(|e| format!("JSON serialization error: {}", e))?;

    Ok(())
}

fn run_demo() {
    println!("{}", "╔════════════════════════════════════════════════════════╗".bright_cyan());
    println!("{}", "║         Package I - Rust Data Processing CLI          ║".bright_cyan());
    println!("{}", "╚════════════════════════════════════════════════════════╝".bright_cyan());
    println!();

    // Statistics demo
    println!("{}", "📊 Statistical Analysis".bright_yellow().bold());
    let numbers = vec![10.0, 20.0, 30.0, 40.0, 50.0];
    println!("  Numbers: {:?}", numbers);
    if let Some(avg) = calculate_average(&numbers) {
        println!("  {}: {}", "Average".cyan(), format!("{:.1}", avg).green());
    }
    let mut nums = numbers.clone();
    if let Some(median) = find_median(&mut nums) {
        println!("  {}: {}", "Median".cyan(), format!("{:.1}", median).green());
    }
    println!();

    // Word frequency demo
    println!("{}", "📝 Word Frequency Analysis".bright_yellow().bold());
    let text = "rust is awesome rust makes systems programming fun";
    println!("  Text: \"{}\"", text.bright_black());
    let freq = word_frequency(text);
    let mut words: Vec<_> = freq.iter().collect();
    words.sort_by(|a, b| b.1.cmp(a.1));
    for (word, count) in words.iter().take(3) {
        println!("  {}: {}", word.cyan(), count.to_string().green());
    }
    println!();

    // Email validation demo
    println!("{}", "📧 Email Validation".bright_yellow().bold());
    let emails = vec!["user@example.com", "invalid", "test@rust.dev"];
    for email in emails {
        let status = if validate_email(email) { "✓".green() } else { "✗".red() };
        println!("  {} {}", status, email.bright_white());
    }
    println!();

    // User management demo
    println!("{}", "👤 User Management".bright_yellow().bold());
    let user = User {
        id: 42,
        name: "Alice Johnson".to_string(),
        email: "alice@rust.dev".to_string(),
        active: true,
    };
    print_user(&user);
    println!();

    println!("{}", "✨ All features working correctly!".bright_green().bold());
    println!();
    println!("{}", "Try these commands:".bright_cyan());
    println!("  {} package-i stats --numbers 10,20,30,40,50", "$".bright_black());
    println!("  {} package-i frequency --text \"your text here\"", "$".bright_black());
    println!("  {} package-i email --address user@example.com", "$".bright_black());
    println!("  {} package-i user --id 1 --name \"John\" --email john@example.com", "$".bright_black());
}
