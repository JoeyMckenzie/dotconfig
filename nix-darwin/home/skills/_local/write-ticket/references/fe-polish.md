# [FE] Show "Thanks for you feedback!" toaster when feedback has been applied

> FE polish, sourced from teammate feedback · 2 points

Per @alex:

> Is the feedback supposed to be a toast that says "Thank you for your feedback!"? I thought it was text replacing the thumbs up/down buttons in the same place. Correct me if I'm wrong.

We recently wired up feedback for the generation though missed a piece to show the toaster regarding the thank you message. Similar to the insights feature, we should pop the toaster when the user clicks the thumbs up/thumbs down buttons.

## Acceptance Criteria

- [ ] When a users clicks thumbs up/thumbs down on a smart suggestion in the draft start card, show the toaster message
- [ ] Message should appear regardless of the option they choose
