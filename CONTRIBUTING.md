# Markdown Contribution Standards

All documentation and markdown files must:

1. **Specify a language for every fenced code block**
   - Example:

     ```json
     { "key": "value" }
     ```

2. **Add a blank line before and after every heading, list, and code block**
3. **Align all table columns and ensure proper spacing**
4. **Avoid multiple consecutive blank lines**
5. **Run `markdownlint` locally before submitting PRs**
   - Install: `npm install -g markdownlint-cli`
   - Run: `markdownlint docs/**/*.md`
6. **Fix all markdownlint errors and warnings before merging**
7. **Use consistent indentation for lists (2 spaces recommended)**
8. **Do not commit files with unresolved markdownlint errors**

## Enforcement

- PRs with markdownlint errors will be rejected.
- Use pre-commit hooks or CI to automatically lint markdown files.

---

Add these instructions to your `CONTRIBUTING.md` or `README.md` to help contributors avoid introducing markdown errors. If you want an automated pre-commit hook or CI config, let me know!
