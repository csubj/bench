## Writing rule: Simplified Technical English

Write every comment, document, and architecture description in Simplified
Technical English (ASD-STE100). This rule covers code comments, docstrings,
error messages, log lines, tool descriptions, README files, architecture
documents, ADRs, commit messages, and pull request descriptions. It does not
cover marketing copy or creative text.

References. Read one only if this rule does not answer your question:

- [Simplified Technical English](https://en.wikipedia.org/wiki/Simplified_Technical_English)
- [asd-ste100 skill](https://github.com/danyuchn/asd-ste100-skill)

### Two levels

**Strict** — code comments, docstrings, error messages, log lines, tool
descriptions, and instructions for other agents. A wrong reading costs real
time here. Apply every rule below.

**STE-flavored** — README files, architecture documents, ADRs, commit messages,
and pull request descriptions. Apply the structural rules. Treat the word choice
rules as advice.

### Structural rules

- Use active voice. Name the actor: "The parser rejects the file."
- Write one instruction per sentence.
- Use 20 words or less for an instruction. Use 25 words or less for a description.
- Use simple tenses. Keep a compound tense only when the simple tense loses information.
- Use no semicolons. Write two sentences instead.
- Use no phrasal verbs. Write "start the job", not "spin up the job".
- Stack 3 words or less in a noun phrase.
- Keep the subject, the verb, and the article explicit.
- Use a list for 3 or more steps or conditions.
- Keep one topic per paragraph, and 6 sentences or less.

### Word choice

- Use one word for one meaning. Do not rotate synonyms for the same thing.
- Use the verb, not the noun. Write "analyze the log", not "perform an analysis of the log".
- Delete adjectives that claim quality: seamless, robust, powerful, blazing-fast.
- Delete stacked hedges. State the claim, or remove it.
- Define a domain term one time if it is not common English.

### Limits

- Keep every hedge that the source states. "May have failed" is not "failed".
- Add no fact that the source does not state.
- Keep the longer sentence if a shorter sentence loses a condition, a scope, or a number.
- Stop when the text is unambiguous, not when it is shortest.

For a full rewrite with the rule tables and worked examples, use the
`asd-ste100` skill.
