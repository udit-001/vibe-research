# Technical Research Reference

## When to Use This Reference

Consult this document when your research involves technical evaluation, code-level investigation, debugging, or technology comparison. For general business, market, or content research, the main Deep Research skill is sufficient.

---

## Technical Evaluation Framework

### Library/Framework Assessment

When evaluating a technical tool or library:

1. **Capability Analysis**
   - What problem does it solve?
   - What are its core features?
   - What are its limitations and constraints?
   - Does it support your use case natively or require workarounds?

2. **Integration Assessment**
   - Language/runtime compatibility
   - Dependency footprint (direct and transitive)
   - Build tool integration
   - Configuration complexity
   - Migration path from current solution

3. **Performance Characteristics**
   - Benchmarks (if available)
   - Resource usage (memory, CPU, bundle size)
   - Scalability limits
   - Startup/warmup time

4. **Ecosystem Health**
   - Documentation quality and completeness
   - Community size and activity
   - Plugin/extension ecosystem
   - Commercial backing (if any)

### Architecture Comparison

When comparing technical architectures or approaches:

| Criterion | Questions to Answer |
|-----------|-------------------|
| Complexity | How complex is the setup? What's the cognitive load? |
| Scalability | How does it handle growth? Horizontal vs vertical? |
| Maintainability | How easy to debug, monitor, and modify? |
| Cost | Infrastructure, licensing, operational costs |
| Team Fit | Does it match team's existing skills? |
| Risk | What's the blast radius if it fails? |

---

## Debugging Research

### Error Investigation Workflow

1. **Isolate the error**
   - Exact error message and stack trace
   - Environment details (versions, OS, config)
   - Reproduction steps
   - Frequency (consistent, intermittent, load-related)

2. **Search for known issues**
   - Search exact error message
   - Search without variable parts (e.g., `"Cannot read property"` instead of `"Cannot read property 'foo' of undefined"`)
   - Search with technology name + error
   - Check official issue trackers and forums

3. **Analyze root causes**
   - Version mismatch
   - Configuration error
   - Missing dependency
   - Breaking change in update
   - Environment-specific issue
   - Race condition or timing issue

4. **Evaluate solutions**
   | Solution Type | When to Use | Risk Level |
   |--------------|-------------|------------|
   | Upgrade | Bug is fixed in newer version | Low-Medium |
   | Downgrade | Bug introduced in recent version | Low |
   | Patch/Workaround | No fix available yet | Medium |
   | Alternative library | Fundamental issue with tool | High |
   | Configuration fix | Misconfiguration identified | Low |

### Performance Issue Research

When investigating performance problems:

1. **Profile first**: Identify actual bottlenecks before optimizing
2. **Search for known performance issues**: `"technology" performance problems`, `"technology" slow`, `"technology" memory leak`
3. **Check benchmarks**: Independent benchmarks vs vendor claims
4. **Review optimization guides**: Official docs, community best practices
5. **Consider alternatives**: If fundamental performance limitations exist

---

## Technology Comparison

### Technical Comparison Criteria

Beyond the general comparison framework, technical evaluations should include:

**Security**
- Security track record (CVE history)
- Authentication/authorization capabilities
- Data handling and privacy
- Compliance certifications (if relevant)

**Operational Characteristics**
- Deployment complexity
- Monitoring and observability
- Error handling and recovery
- Backup and disaster recovery

**Development Experience**
- API design quality
- Type safety
- IDE support
- Testing utilities
- Debugging tools

**Long-term Viability**
- Roadmap and future plans
- Backward compatibility commitment
- Deprecation policy
- Vendor lock-in risk

---

## Code-Level Research

### Reading Code Effectively

When you need to understand how something works internally:

1. **Start with the entry point**: Main function, public API, or request handler
2. **Follow the data flow**: Trace how input transforms to output
3. **Identify key abstractions**: Core classes, functions, or modules
4. **Look for patterns**: Design patterns, conventions, architectural style
5. **Check edge cases**: Error handling, boundary conditions, validation

### API Research

When evaluating an API:

1. **Read the official documentation**
2. **Check for OpenAPI/Swagger specs** (if applicable)
3. **Look for SDK/client libraries**
4. **Review rate limits and quotas**
5. **Check authentication methods**
6. **Search for integration examples**
7. **Look for breaking changes history**

---

## Infrastructure Research

### Cloud Service Evaluation

When comparing cloud services or platforms:

1. **Feature parity**: Does it support required features?
2. **Pricing model**: Pay-per-use, reserved, spot, etc.
3. **SLA guarantees**: Uptime, support response times
4. **Compliance**: SOC2, GDPR, HIPAA, etc.
5. **Vendor lock-in**: Migration difficulty, data portability
6. **Regional availability**: Data center locations, latency

### Self-Hosted vs Managed

| Factor | Self-Hosted | Managed/SaaS |
|--------|------------|--------------|
| Control | Full | Limited |
| Operational overhead | High | Low |
| Customization | Unlimited | Constrained |
| Cost at scale | Often lower | Often higher |
| Expertise required | Deep | Moderate |
| Time to production | Longer | Shorter |

---

## Research Output for Technical Decisions

### Technical Recommendation Format

```markdown
## Recommendation: [Technology/Approach Name]

### Confidence: [High/Medium/Low]

### Quick Summary
[2-3 sentence overview]

### Why This Choice
- [Key reason 1]
- [Key reason 2]
- [Key reason 3]

### Trade-offs Accepted
- [Trade-off 1]: [Why it's acceptable]
- [Trade-off 2]: [Mitigation strategy]

### Implementation Notes
- [Setup step 1]
- [Setup step 2]
- [Configuration detail]

### Risks and Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [Strategy] |

### Alternatives Considered
- [Alternative 1]: [Why rejected]
- [Alternative 2]: [Why rejected]

### Resources
- [Documentation link]
- [Tutorial link]
- [Reference implementation]
```

---

## Technical Research Best Practices

1. **Prototype before committing**: Build a small proof-of-concept
2. **Check version compatibility**: Ensure it works with your stack
3. **Read the source**: For critical dependencies, review the actual code
4. **Test edge cases**: Verify it handles your specific use cases
5. **Check maintenance burden**: Who will maintain this long-term?
6. **Evaluate exit strategy**: How hard to replace if it doesn't work out?
7. **Consider total cost**: Not just licensing, but operational and learning costs

---

## Anti-Patterns in Technical Research

- **Hype-driven adoption**: Choosing based on popularity rather than fit
- **Over-engineering**: Choosing complex solutions for simple problems
- **Not-invented-here**: Rejecting proven solutions to build custom
- **Latest-and-greatest**: Using bleeding edge without need
- **Ignoring operational costs**: Only considering development, not maintenance
- **Single-point-of-failure**: Depending on one person's expertise
- **No migration plan**: Adopting without considering how to move away

---

*This reference covers technical research workflows. For GitHub-specific research (repository analysis, issue search, commit history), see `github-research.md`.*