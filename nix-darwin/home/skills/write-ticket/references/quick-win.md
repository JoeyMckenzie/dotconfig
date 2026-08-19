# Add command to run NCF backfills

> RAISE-3322 · Quick win · 2 points

I've found a few scenarios that would be helpful if I was able to programmatically kickoff an NCF backfill through an artisan command so we can target NCF backfills per account. This opens up the possibility of running NCF backfills en mass if we ever need to as well.

## Acceptance Criteria

- [ ] Add an artisan command that kicks off backfills for NCF given an account ID
- [ ] Should run through all the ingestors
- [ ] Run it for butter world in production

---

A second quick-win example, with an explicit non-goal in the acceptance criteria:

# [BE] Filter out common websites before sending scrape to Firecrawl

> RAISE-3194 · Quick win · 2 points

We've been relying on Firecrawl to kick out URLs like Facebook and Instagram, though I noticed a few accounts using Givebutter seemingly to get past the signup screen. We should bypass the scrape for a list of common sites so we don't send them to Firecrawl in the first place and scrape nonsensical websites. To start:

* instagram.com
* facebook.com
* Any other major social media
* givebutter.com

## Acceptance Criteria

- [ ] When a user signs up with a nonsensical URL, there should be no entries in the `website_scrapes` table for it
- [ ] We don't need alerts here, just silently bypass the job and log out the bypass context
