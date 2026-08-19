# [BE] Add `website` domain model for NPOs

> RAISE-3320 · Domain modeling · 4 points

Based on @davor.minchorov's research within [RAISE-3233](https://linear.app/givebutter/issue/RAISE-3233/spike-explore-updating-website-site-scrapes-for-account-less-scenarios), Davor created some amazing ADRs for us [here](https://github.com/givebutter/monorepo/pull/9095/changes). The proposal we've agreed upon is [option B.](https://github.com/givebutter/monorepo/pull/9095/changes#diff-78f9be953c4f42bc66d391460aff7e4bd77b82c82f6dd69c2974b52569363847) For our purposes in core fundraising, this means that we will begin to treat a website as a domain model and keep the website scrapes table in domain model separate and treat it almost like an event log of things that happen to a website. We think this will give us the most flexibility in how to treat website scrapes, and furthermore we won't be overloading the website scrapes domain model with things that might not be related to the website scrape itself.

The intention of this story is to carve out a new website's domain that is almost like a subdomain of an account. As an account more or less owns a website, and we are now moving away from the idea of website just being a field on the account and being more so related to a domain model. This is in support of us needing to scrape nearly 2 million websites.

## Acceptance Criteria

- [ ] Use Davor's research as a jumping off point for modeling the website model
- [ ] Expect to load this table up with ~2M entries
- [ ] Ideally, a website has a one-to-many with `website_scrapes`
- [ ] `website_scrapes` is now an event log of an *action* taken on a website (i.e. a scrape run)
