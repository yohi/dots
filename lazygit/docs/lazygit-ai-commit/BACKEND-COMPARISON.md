# AI Backend Comparison

Quick reference to help you choose the right AI backend for your needs.

## At a Glance

| Feature | Gemini | Claude | Ollama | Mock |
|---------|--------|--------|--------|------|
| **Speed** | ⚡⚡⚡ Fast (1-3s) | ⚡⚡ Medium (2-5s) | ⚡ Slow (5-15s) | ⚡⚡⚡ Instant |
| **Quality** | ⭐⭐⭐ Good | ⭐⭐⭐⭐ Excellent | ⭐⭐ Fair | ⭐ Basic |
| **Cost** | 💰 Free tier + cheap | 💰💰 Paid only | 🆓 Free | 🆓 Free |
| **Privacy** | ☁️ Cloud | ☁️ Cloud | 🔒 Local | 🔒 Local |
| **Setup** | ✅ Easy | ✅ Easy | ⚙️ Moderate | ✅ None |
| **Internet** | ✅ Required | ✅ Required | ❌ Not needed | ❌ Not needed |
| **Best For** | Most users | Quality-focused | Privacy-sensitive | Testing |

## Detailed Comparison

### Speed

**Gemini** (1-3 seconds)
- Fastest cloud option
- Optimized for quick responses
- Rarely times out
- ✅ Best for: Fast-paced development

**Claude** (2-5 seconds)
- Slightly slower than Gemini
- Still very responsive
- Consistent performance
- ✅ Best for: When quality > speed

**Ollama** (5-15 seconds)
- Depends on your hardware
- Faster with GPU acceleration
- Can be slow on older machines
- ✅ Best for: When you can wait for privacy

**Mock** (< 1 second)
- Instant responses
- No AI processing
- Simple heuristics
- ✅ Best for: Testing and CI/CD

### Quality

**Claude** ⭐⭐⭐⭐
- Best understanding of code context
- Most accurate commit messages
- Excellent at following Conventional Commits
- Rarely produces off-topic messages
- ✅ Best for: Professional projects

**Gemini** ⭐⭐⭐
- Good quality overall
- Occasionally generic messages
- Usually follows format correctly
- Good balance of speed and quality
- ✅ Best for: Most projects

**Ollama** ⭐⭐
- Quality varies by model
- Mistral: decent quality
- CodeLlama: better for code
- May need prompt tuning
- ✅ Best for: When privacy matters more than perfection

**Mock** ⭐
- Basic keyword matching
- Generic messages
- No real understanding
- Consistent but simple
- ✅ Best for: Testing only

### Cost

**Ollama** 🆓
- Completely free
- Only electricity costs
- No usage limits
- No API keys needed
- ✅ Best for: Budget-conscious or high-volume users

**Gemini** 💰
- Generous free tier (15 req/min)
- Very cheap paid tier ($0.00025/1K chars)
- ~$0.01/month for typical usage
- ~$0.10/month for heavy usage
- ✅ Best for: Most users (essentially free)

**Claude** 💰💰
- No free tier
- Haiku: $0.25/million tokens
- ~$0.25/month for typical usage
- ~$1.50/month for heavy usage
- ✅ Best for: When quality justifies cost

**Mock** 🆓
- Free
- No costs at all
- ✅ Best for: Testing

### Privacy & Security

**Ollama** 🔒🔒🔒
- Everything stays local
- No data sent externally
- Full control over data
- Complies with strict policies
- ✅ Best for: Proprietary/sensitive code

**Mock** 🔒🔒
- Local processing
- No external calls
- No data collection
- ✅ Best for: Testing sensitive projects

**Gemini** ☁️
- Code sent to Google servers
- Subject to Google's privacy policy
- Data may be used for improvements
- ⚠️ Review diffs before generating
- ✅ Best for: Open source or non-sensitive code

**Claude** ☁️
- Code sent to Anthropic servers
- Subject to Anthropic's privacy policy
- Data not used for training (per policy)
- ⚠️ Review diffs before generating
- ✅ Best for: Open source or non-sensitive code

### Setup Difficulty

**Mock** ✅✅✅
- No setup required
- Works out of the box
- No dependencies
- ✅ Best for: Quick testing

**Gemini** ✅✅
- One command: `pip install google-generativeai`
- Get API key from website
- Set environment variable
- 5 minutes total
- ✅ Best for: Quick production setup

**Claude** ✅✅
- One command: `npm install -g @anthropic-ai/claude-cli`
- Get API key from website
- Add credits to account
- Set environment variable
- 10 minutes total
- ✅ Best for: When you want best quality

**Ollama** ⚙️
- Install Ollama
- Pull model (large download)
- Start service
- Configure to run on boot
- 15-30 minutes total
- ✅ Best for: Long-term privacy solution

### Internet Requirement

**Cloud (Gemini/Claude)**
- ✅ Requires stable internet
- ❌ Won't work offline
- ⚠️ Affected by network issues
- ⚠️ Blocked by some corporate firewalls

**Local (Ollama/Mock)**
- ✅ Works offline
- ✅ No network dependency
- ✅ Works behind firewalls
- ✅ No latency from network

## Use Case Recommendations

### Individual Developer (Open Source)
**Recommended: Gemini**
- Fast and free
- Good quality
- Easy setup
- Code is public anyway

### Individual Developer (Private Projects)
**Recommended: Ollama**
- Privacy-focused
- No recurring costs
- Works offline

### Small Team
**Recommended: Gemini**
- Cost-effective
- Consistent quality
- Easy for everyone to set up

### Enterprise/Corporate
**Recommended: Ollama**
- Meets compliance requirements
- No data leaving network
- No per-user costs
- Full control

### Quality-Focused Developer
**Recommended: Claude**
- Best commit messages
- Worth the small cost
- Professional results

### High-Volume User (200+ commits/day)
**Recommended: Ollama**
- No API costs
- No rate limits
- Consistent performance

### Testing/CI/CD
**Recommended: Mock**
- No API keys in CI
- Fast and reliable
- No external dependencies

### Offline Developer
**Recommended: Ollama**
- Only option that works offline
- No internet required

## Migration Path

### Start → Grow → Scale

**Phase 1: Testing**
```bash
export AI_BACKEND=mock
```
- Test the integration
- Learn the workflow
- No setup required

**Phase 2: Production (Individual)**
```bash
export AI_BACKEND=gemini
export GEMINI_API_KEY="your-key"
```
- Real AI quality
- Free tier sufficient
- Easy to set up

**Phase 3: Scale (Team/Enterprise)**
```bash
export AI_BACKEND=ollama
ollama serve
```
- Privacy compliant
- Cost-effective at scale
- Full control

## Quick Decision Tree

```
Do you need it for testing only?
├─ Yes → Mock
└─ No → Do you have privacy/compliance requirements?
    ├─ Yes → Ollama
    └─ No → Do you need the absolute best quality?
        ├─ Yes → Claude
        └─ No → Gemini
```

## Switching Backends

You can easily switch between backends:

```bash
# Try Gemini
export AI_BACKEND=gemini
lazygit

# Switch to Ollama
export AI_BACKEND=ollama
lazygit

# Back to mock for testing
export AI_BACKEND=mock
lazygit
```

No code changes needed - just change the environment variable!

## Performance Benchmarks

Based on typical usage (500 byte diff):

| Backend | Avg Time | P95 Time | Timeout Rate |
|---------|----------|----------|--------------|
| Gemini | 1.5s | 3s | < 0.1% |
| Claude | 2.5s | 5s | < 0.1% |
| Ollama (CPU) | 8s | 15s | < 1% |
| Ollama (GPU) | 4s | 8s | < 0.5% |
| Mock | 0.1s | 0.2s | 0% |

## Cost Estimates

Based on 50 commits/day, 500 bytes avg diff:

| Backend | Daily Cost | Monthly Cost | Yearly Cost |
|---------|------------|--------------|-------------|
| Gemini (free) | $0 | $0 | $0 |
| Gemini (paid) | $0.0003 | $0.01 | $0.12 |
| Claude | $0.008 | $0.25 | $3.00 |
| Ollama | $0 | $0 | $0 |
| Mock | $0 | $0 | $0 |

## Summary

**Most users should start with Gemini** - it's fast, free, and good quality.

**Switch to Ollama if**:
- You work on sensitive/proprietary code
- You need to work offline
- You make 200+ commits per day
- Your organization requires it

**Upgrade to Claude if**:
- You need the absolute best quality
- You're willing to pay for perfection
- You're working on critical projects

**Use Mock for**:
- Testing the integration
- CI/CD pipelines
- Demonstrating the feature

## Need Help Deciding?

Ask yourself:

1. **Is my code sensitive?** → Yes = Ollama, No = continue
2. **Do I need best quality?** → Yes = Claude, No = continue
3. **Do I want free?** → Yes = Gemini

Still unsure? **Start with Gemini** - you can always switch later!
