# Week 1 Retrospective

## Overview
This week focused on building an engineering mindset through hands-on terminal work, Node.js exploration, Git mastery, HTTP/API analysis, and automation.

---

## Key Learnings

### Day 1: System & Node Mastery

**What I Learned:**
* Deep understanding of `PATH` and environment variables
* How the Node.js runtime works internally
* Performance differences between Streams and Buffers

**Key Insight:** Streams are drastically more memory-efficient for large files. The 50MB file test showed:
* **Buffer:** ~52MB memory usage
* **Stream:** ~12MB memory usage (**~76% reduction**)

**Challenges:**
* Understanding NVM's `PATH` manipulation
* Properly benchmarking with garbage collection

**What Broke:**
* First attempt at stream benchmark didn't account for async completion
* **Solution:** Used proper Promise handling with event listeners

---

### Day 2: Asynchronous Programming

**What I Learned:**
* Worker Threads enable true parallelism in Node.js
* `Promise.all` for concurrent operations
* CLI argument parsing techniques

**Key Insight:** Concurrency doesn't always mean faster:
* Concurrency 1 → ~1200ms
* Concurrency 4 → ~450ms
* Concurrency 8 → ~480ms (overhead outweighed benefits)

**Challenges:**
* Merging frequency maps from multiple workers
* Properly splitting large files into chunks

**What Broke:**
* Initial implementation had race conditions
* **Solution:** Used proper `Promise.all` synchronization

---

### Day 3: Git Mastery

**What I Learned:**
* `git bisect` is extremely powerful for bug hunting
* Difference between `reset` (destructive) and `revert` (safe)
* Stash workflow for context switching

**Key Insight:**  **Never use `git reset --hard` on shared branches.** Always prefer `git revert` for published commits.

**Challenges:**
* Understanding detached `HEAD` state during bisect
* Resolving merge conflicts correctly

**What Broke:**
* Lost work by accidentally using `git reset --hard`
* **Solution:** Used `git reflog` to recover lost commits

---

### Day 4: HTTP & APIs

**What I Learned:**
* How ETags enable efficient caching
* DNS resolution and network routing basics
* Impact of request and response headers

**Key Insight:** `304 Not Modified` responses save bandwidth and dramatically improve performance for APIs serving frequently accessed data.

**Challenges:**
* Extracting ETag values from headers using bash
* Understanding CORS and preflight (`OPTIONS`) requests

**What Broke:**
* Server didn't handle `OPTIONS` requests initially
* **Solution:** Added an explicit `OPTIONS` request handler

---

### Day 5: Automation & CI

**What I Learned:**
* Husky simplifies Git hook management
* Combining linting + validation creates strong quality gates
* Scheduled tasks help with ongoing monitoring

**Key Insight:** Pre-commit hooks prevent bad code from entering the repository, saving hours of debugging later.

**Challenges:**
* Making `validate.sh` work cross-platform
* JSON validation without external dependencies

**What Broke:**
* Pre-commit hook lacked execute permissions
* **Solution:** `chmod +x .husky/pre-commit`

---

## Skills Acquired

1.  Terminal fluency (bash, PATH, environment variables)
2.  Node.js internal architecture
3.  Asynchronous programming patterns
4.  Git workflow expertise
5.  HTTP protocol understanding
6.  Automation scripting
7.  CI/CD fundamentals

---

## Tools Mastered

* **CLI:** curl, nslookup, traceroute, cron
* **Node.js:** fs, streams, worker_threads, http
* **Git:** bisect, revert, stash, cherry-pick
* **Dev Tools:** ESLint, Prettier, Husky

---

## Mistakes & Lessons

1. **Mistake:** Used `var` instead of `const` / `let` 
   **Lesson:** ESLint caught this immediately

2. **Mistake:** Forgot to `await` Promises 
   **Lesson:** Always use `async/await` properly

3. **Mistake:** Committed code without testing 
   **Lesson:** Pre-commit hooks saved me

4. **Mistake:** Didn't document progress daily 
   **Lesson:** Documentation is easiest when written while work is fresh

---

## Final Reflection

Week 1 significantly strengthened my engineering fundamentals. The combination of low-level system understanding, practical Node.js internals, disciplined Git usage, and automation-first thinking laid a strong foundation for scalable and maintainable software development.
