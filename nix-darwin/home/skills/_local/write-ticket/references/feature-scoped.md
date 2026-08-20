# [BE] Offload scraped images out of RDS

> Scoped improvement · 4 points

CrawlKit returns `branding.images.logo` as a base64 data: URI (almost always inline SVG, sometimes PNG/WebP) rather than a URL, and we store it directly in `website_scrapes.logo_url`. This was a shortcut, and now we need to redesign how we store the images out of the database into something more form-fit for the purposes of scrapes and smart drafts.

Widening the column to mediumtext stops the crash, but keeps image blobs in a queryable DB column. That is a stopgap, not the fix.

## Goal

Keep `logo_url` (and image fields generally) as short, queryable URLs. When CrawlKit returns an inline image, decode it, store it in S3/CDN, and persist the resulting URL. The DB holds metadata and references, not image bytes.

## Scope

* Detect inline data: image values during scrape ingestion and offload them to S3/CDN, storing the resulting URL
* Stop persisting the duplicated base64 blob in raw_response
* Backfill the existing data-URI rows to S3/CDN URLs
* Treat image upload as non-critical, so a failed upload should `null` the image and let the scrape complete, not fail the whole scrape

A few things to consider are that SVGs can embed scripts. We should at least attempt to sanitize and/or serve from a dedicated non-executable CDN host, since these render in-product on the profile page when a user goes through smart drafts initially. I think we're okay to use S3 here, though we can explore throwing these in our CDN as well as they're primarily just images for the sake of smart drafts (for now).

## Acceptance criteria

- [ ] New scrapes with inline logos store an S3/CDN URL in logo_url, never base64
- [ ] `raw_response` no longer contains the base64 image blob
- [ ] Existing data-URI rows are backfilled to URLs
- [ ] A failed image upload nulls the image and the scrape still completes
