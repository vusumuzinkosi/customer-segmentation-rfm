# Customer Segmentation: RFM and K-means for Targeted Campaigns

## 1. Business problem

**Client and context.** The imagined client is a South African online retailer of gifts and homeware that sells to individual shoppers and to small shops (gift stores, decor boutiques). Today marketing sends **everyone the same email**: the same products, the same discount, the same timing.

**Question.** Which natural groups exist in the customer base, and what should marketing say to each?

**What marketing would do differently per segment:**

- **Where to spend:** loyalty perks and account management for the most valuable customers, instead of discounts they do not need.
- **Who to win back:** customers who used to buy regularly and have gone quiet, while they are still worth saving.
- **Who to grow:** new customers who need a reason to place their next order.
- **Who to stop chasing:** long-lost one-time buyers, kept only in low-cost seasonal campaigns.

**What a good result looks like.** A handful of segments (three to five) that are clearly different, easy to describe in one sentence, large enough to run a campaign for, and that **predict future buying** rather than only describing the past. Segments a marketing manager cannot name or act on are not useful, however good the statistics.

## 2. Data

**Source:** [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii), UCI Machine Learning Repository, id 502 (CC BY 4.0). Every transaction of a UK-based online gift and homeware retailer from 1 December 2009 to 9 December 2011: 1,067,371 invoice lines in an Excel workbook with one sheet per year. Many of its customers are small shops buying in bulk, which is the same mix as the imagined client.

| Column | Meaning |
|---|---|
| `Invoice` | Invoice number. Starts with **C** for a cancellation, **A** for a bad-debt adjustment. |
| `StockCode` | 5-digit product code, sometimes with a variant letter (`85123A`). Non-products include `POST` (postage), `M` (manual), `BANK CHARGES`, `AMAZONFEE`. |
| `Description` | Product name |
| `Quantity` | Units on the line; negative for cancellations |
| `InvoiceDate` | Date and time of the invoice |
| `Price` | Unit price in pounds sterling |
| `Customer ID` | Customer number; missing for almost a quarter of lines |
| `Country` | Customer's country (91% of customers are in the UK) |

**Currency.** Amounts are in pounds. I keep them in pounds rather than inventing an exchange rate; the segments and campaigns translate directly to a rand-based business.

**South African data in a real role:** the retailer's own e-commerce order history and loyalty programme data, processed under POPIA. Customer-level retail data is rarely public in South Africa, which is why an international dataset is used here.
