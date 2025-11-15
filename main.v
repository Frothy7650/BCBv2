module main
import json
import rand
import os


fn main()
{
  // Variable zone

  // Profile path/name
  mut profile_path := ''
  $if windows {
    profile_path = os.join_path(os.getenv("APPDATA"), "BCB")
  } $else {
    profile_path = os.join_path(os.getenv("HOME"), ".config", "BCB")
  }
  mut profile_name := ''

  // Clear command
  mut clear_command := ''
  $if windows {
    clear_command = "cls"
  } $else {
    clear_command = "clear"
  }

  // Prompt for profile_name and handle if empty
  profile_name = os.input("Enter profile name: ")
  if profile_name == '' { eprintln("Error: profile_name is empty or using invalid charachters: ${profile_name}")}
  if !profile_name.ends_with(".json") { profile_name += ".json" }

  // Load ${profile_name}.json
  profile_raw_in := os.read_file(os.join_path(profile_path, profile_name)) or { panic(err) }
  mut profile_json := json.decode(map[string][]string, profile_raw_in) or { panic(err) }

  // Clear screen and start the question-answer loop
  os.system(clear_command)
  for { q_and_a(clear_command, mut profile_json, profile_path, profile_name) }
}

fn q_and_a(clear_command string, mut profile_json map[string][]string, profile_path string, profile_name string)
{
  // Print You: and check for keywords
  question := os.input("You: ")
  match true
  {
    question == "/exit" || question == "quit" { exit(0) }
    question == "/clear" { os.system(clear_command) }
    question == "/clean answer" {
      clean_answer := os.input("Enter answer to clean: ")
      profile_json.delete(clean_answer)
      profile_raw_out := json.encode_pretty(profile_json)
      os.write_file(os.join_path(profile_path, profile_name), profile_raw_out) or { panic(err) }
      println("Removed ${clean_answer}")
      return
    }
    question == "/clean" { os.write_file(os.join_path(profile_path, profile_name), "{}") or { panic(err) } }
    question == "" { return }
    else {}
  }

  // Search through for question in profile_json
  if question in profile_json {
    answers := profile_json[question]
    random_index := rand.int_in_range(0, answers.len) or { 0 }
    println("Bot: ${answers[random_index]}")
  } else {
    question_answer := os.input("Answer: ")
    if question_answer == "skip" { return }

    // Search through and print
    if question in profile_json {
      profile_json[question] << question_answer
    } else {
      profile_json[question] = [question_answer]
    }
    profile_raw_out := json.encode_pretty(profile_json)
    os.write_file(os.join_path(profile_path, profile_name), profile_raw_out) or { panic(err) }
  }
}
