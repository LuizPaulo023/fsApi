# Load the tidyverse package
library(tidyverse)

# Create a sequence of letters from A to Z
letter_sequence <- LETTERS

# Initialize an empty vector to store the final sequence
final_sequence <- character(0)

# Append the sequence with letters and numbers (A001 to Z999)
for (letter in letter_sequence) {
  final_sequence <- c(final_sequence, sprintf("%s%03d", letter, 1:999))
}

# Append the sequence with letters and numbers (AA01 to ZZ99)
for (letter1 in letter_sequence) {
  for (letter2 in letter_sequence) {
    final_sequence <- c(final_sequence, sprintf("%s%s%02d", letter1, letter2, 1:99))
  }
}

# Append the sequence with letters and numbers (AAA1 to ZZZ9)
for (letter1 in letter_sequence) {
  for (letter2 in letter_sequence) {
    for (letter3 in letter_sequence) {
      final_sequence <- c(final_sequence, sprintf("%s%s%s%01d", letter1, letter2, letter3, 1:9))
    }
  }
}

# Append the sequence with letters only (AAAA to ZZZZ)
for (letter1 in letter_sequence) {
  for (letter2 in letter_sequence) {
    for (letter3 in letter_sequence) {
      for (letter4 in letter_sequence) {
        final_sequence <- c(final_sequence, paste0(letter1, letter2, letter3, letter4))
      }
    }
  }
}
final_sequence <- c(sprintf('%04d', 603:9999), final_sequence)

# Export sequence generated
writexl::write_xlsx(tibble(final_sequence), 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/curadoria/anbima/seq_ind_anb.xlsx')
