# Add command to run context backfills

> Quick win · 2 points

I've found a few scenarios that would be helpful if I was able to programmatically kickoff a context backfill through an artisan command so we can target context backfills per account. This opens up the possibility of running context backfills en mass if we ever need to as well.

## Acceptance Criteria

- [ ] Add an artisan command that kicks off context backfills given an account ID
- [ ] Should run through all the ingestors
- [ ] Run it for our sandbox account in production

---

A second quick-win example, with an explicit non-goal in the acceptance criteria:

# [BE] Filter out common websites before sending scrape to CrawlKit

> Quick win · 2 points

We've been relying on CrawlKit to kick out URLs like Facebook and Instagram, though I noticed a few accounts using our own domain seemingly to get past the signup screen. We should bypass the scrape for a list of common sites so we don't send them to CrawlKit in the first place and scrape nonsensical websites. To start:

* instagram.com
* facebook.com
* Any other major social media
* our own product domain

## Acceptance Criteria

- [ ] When a user signs up with a nonsensical URL, there should be no entries in the `website_scrapes` table for it
- [ ] We don't need alerts here, just silently bypass the job and log out the bypass context
