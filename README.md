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

## 3. Cleaning

Every rule is applied in order and counted:

| Rule | Lines removed | Lines left |
|---|---|---|
| Raw data | | 1,067,371 |
| Exact duplicate lines | 34,335 | 1,033,036 |
| No Customer ID (cannot be linked to a customer) | 235,151 | 797,885 |
| Cancellations (invoice starts with C) | 18,390 | 779,495 |
| Non-product lines (postage, fees, manual entries) | 2,858 | 776,637 |
| Zero or negative quantity or price | 60 | **776,577** |

Cancellations are **removed, not subtracted**: many refer to orders placed before the data starts, and subtracting them would leave some customers with negative spend. Revenue per line is `Quantity x Price`.

**Result:** 5,852 customers, 36,594 orders, £17.1 million in revenue.

![Monthly revenue](figures/monthly_revenue.png)

- Sales are **strongly seasonal**, peaking in October and November before Christmas.
- Revenue is **very concentrated**: the top 10% of customers bring in 64% of it.
- Almost a quarter of all lines have **no Customer ID**. That revenue is real but cannot be segmented; in a real project I would ask why (for example, guest checkout).

## 4. Baseline: RFM by hand

For every customer, measured on 10 December 2011:

- **Recency:** days since the last order
- **Frequency:** number of orders
- **Monetary:** total spend

Each is scored 1 to 5 by quintile (5 = best) and the three scores are added (3 to 15) into tiers:

| Tier | RFM score | Customers | Median days since last order | Median orders | Median spend | Share of revenue |
|---|---|---|---|---|---|---|
| Gold | 12 to 15 | 1,711 (29%) | 18 | 10 | £3,628 | **80%** |
| Silver | 7 to 11 | 2,378 (41%) | 96 | 3 | £852 | 17% |
| Bronze | 3 to 6 | 1,763 (30%) | 418 | 1 | £240 | 3% |

![RFM tiers](figures/rfm_tiers.png)

**What I expected before clustering:** a small high-value group carrying most of the revenue; a large group of long-gone one-time buyers; and, hidden inside Silver, two groups that need opposite messages: **new customers** (recent, few orders) and **regulars drifting away** (several orders, not recent). If K-means separates those two, it is worth its extra complexity.

## 5. K-means clustering

**Preparation.** Recency, frequency and monetary are all heavily skewed (the biggest customer spent £581,000; the median £856), and they are in different units. K-means works on distances, so without care the few giant customers would dominate. Each value is **log-transformed** (`log1p`) and **standardised** (mean 0, standard deviation 1).

![Transformation](figures/rfm_transform.png)

**Choosing k** (number of clusters), for k = 2 to 10:

| k | 2 | 3 | **4** | 5 | 6 |
|---|---|---|---|---|---|
| Silhouette | 0.438 | 0.347 | **0.365** | 0.342 | 0.336 |

![Choosing k](figures/choosing_k.png)

The silhouette score is highest at k = 2, but "good customers and the rest" adds nothing the RFM tiers do not already say. **k = 4 is a local peak**, the elbow bends around 4 to 5, and four is a number of campaigns a marketing team can run. Statistics narrows the choice; the business use makes it.

**The four clusters:**

| Cluster | Customers | Median days since last order | Median orders | Median spend | Share of revenue |
|---|---|---|---|---|---|
| A | 1,110 (19%) | 15 | 13 | £5,118 | 72% |
| B | 1,468 (25%) | 157 | 5 | £1,580 | 18% |
| C | 1,220 (21%) | 23 | 3 | £708 | 6% |
| D | 2,054 (35%) | 398 | 1 | £291 | 4% |

![Clusters](figures/clusters_scatter.png)
