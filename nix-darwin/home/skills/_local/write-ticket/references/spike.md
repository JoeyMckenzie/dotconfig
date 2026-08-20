# [Spike] Add backfill process for kicking off website scrapes from registry data

> Spike · 4 points

With the recent additions of the website model allowing us to offload responsibility of the `website_scrapes` table into the website domain model instead, we're in a good spot to start building out the integration code that will act as a backfill drip feeding website scrapes through the website scrape job creating records in the `website_scrapes` table, while also beginning to populate the `websites` table for accounts to claim.

This is going to be a somewhat two fold process, where we will first need to check the available orgs we've got in OpenSearch seeded via our registry ingest, then proceed to run through the scraping pipeline + backfill the website table. The process will look something like:

* Whip up an `artisan` command to idempotently kick off the pipeline (can resume if we need to based on what websites we've loaded into the websites table have an associated scrape)
* Query for orgs in the production OpenSearch registry datasets, filtered by those with a populated website (we don't care about validity, CrawlKit will handle that)
* Preseed the `websites` table with all the websites we need to fill, with `last_scraped_at` set to null so we can use it as a place marker if needed (to test in batches, etc. where we could only make sure to scrape websites we know haven't been scraped yet from the `websites` table
* Kick off a batch of scrapes, adjusted on a queue that is sufficiently rate limited WELL below our current CrawlKit usage rate for smart drafts and account settings (ask @joey to add you as an admin to the dashboard if needed)
* Pull a batch of websites with no scrape, run them through the web scraping pipeline, and sync the results back to the `websites` row (@sam has already done a lot of this plumbing to make it easy)

I think the most important part here is figuring out how much we can drip feed scrapes through with a rate limiter. Part of this ticket is doing some quick napkin about how we much volume we can chew through with scrapes while letting active features that rely on them run unimpeded.

Another aspect is that because we expect this process to take a very long time, we should be sure to build in some form of "giant red button" that shuts down the scrapes should we need it. Example being if we kick off all the scrapes and expectedly queue up 1.9M million jobs all at once, we might exhaust supervisors simply just monitoring pending jobs that are already rate limited. One potential solution might be to only queue up some many jobs per day to scrape websites through the scheduler, but we can leave that as an implementation detail.

## Acceptance Criteria

- [ ] Determine a process we can idempotently run for pulling websites from OpenSearch and scraping them
- [ ] Results of the scrape should also create new `websites` rows if the row is missing
- [ ] Two options:
  - [ ] A) Pre fill `websites` table with canonicalized entries and null values elsewhere so we can resume from non-populated records
  - [ ] B) Create the `websites` records after scrape (I think option A here is the better bet)
- [ ] Rate limiter in place for the job that runs/coordinates the backfill (website scrapes already are rate limited, I believe)
