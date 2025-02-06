# UROY 2024

Code and data for my 2024 UROY analysis. See the [Substack Post](https://myhourglass.substack.com/p/people-racing-people) for a much more entertaining rundown of the results and process!

## Results

|| Place || Female | ELO || Male | ELO ||
|--|:---:|----|:----:|:----|----|:---:|:---|---|
|| 1 || Katie Schide | 957 || Hayden Hawks | 1029 ||
|| 2 || Hannah Allgood | 930 || Caleb Olson | 991 ||
|| 3 || Mary Denholm | 906 || David Sinclair | 980 ||
|| 4 || Rachel Drake | 901 || Eli Hemming | 978 ||
|| 5 || Emily Hawgood | 888 || David Roche | 964 ||
|| 6 || Courtney Dauwalter | 886 || Ben Dhiman | 942 ||
|| 7 || Riley Brady | 874 || Harry Subertas | 933 ||
|| 8 || Marianne Hogan | 873 || Adam Peterman | 928 ||
|| 9 || Anne Flower | 869 || Cole Campbell | 919 ||
|| 10 || Lindsay Allison | 867 || Rod Farvard | 887 ||

## Detailed Process

### Step 1: Obtain the Data

I first manually created the file `uroy-results.csv` using information from [ultrarunning.com](https://ultrarunning.com/tag/2024uroy/).
The universe of data considered were all races ran by those ranked in the original UROY rankings in 2024.
In order to webscrape the race results for all 66 races, I created webscrapers for various running results websites. These are stored in `python-code/scrapers.py` and are applied to scrape the data in `python-code/webscrape_results.ipynb`. 
The results of each race were webscraped and saved to the `data/race_results/` directory as a `.csv` file (With some exceptions, as noted in the Other Notes section below).

### Step 2: Clean the Data

At this point, I created the `race-data-map.csv` and `race-info.csv` to help me know where I got data from (for formatting purposes) and get some general info about the race (most importantly, date).
In `r-code/02_create_big_datafile.R` I read in all the race result files, clean the data based on where it came from, and then combine them into big data files. This is done two ways: once including DNFs as a last-place finish, and once excluding DNFs.
I used the file excluding DNFs for the rest of the analysis.

### Step 3: Compute the ELO Rankings

The most interest work occurs in `r-code/04_plots_and_such.R`. This is where the ELO ranking algorithm is created and applied.
For a detailed explanation of the ELO ranking algorithm, see [this Medium article](https://stanislav-stankovic.medium.com/elo-rating-system-6196cc59941e#:~:text=Finally%2C%20we%20do%20not%20want,finally%20start%20to%20rise%20up.). In the case of running, we don't have only a head-to-head matchup but rather a one-vs-many matchup system. I used the process described briefly in the top rated answer to [this Stack Overflow question](https://gamedev.stackexchange.com/questions/55441/player-ranking-using-elo-with-more-than-two-players) and also mentioned [here](https://web.archive.org/web/20130308190719/http://elo.divergentinformatics.com/).
Essentially, it involves computing the ELO change for each person against everyone else in the race, and then modifying the ELO score.

Another key point for my system is what I call a wrapping calendar average. In order to make sure that the order of the races is not important, we compute the 2024 ELO score for each runner twelve times: Once from the beginning of each month, with earlier months wrapping to the end of the schedule.
The final ELO score is the average of those twelve ELO scores.
Another thought on this one would be to randomize the order of the races and calculate the ELO many times, but I have not implemented that here.

In order to minimize the effect of race size on the rankings, I initially was trying to scale the update by the number of the participants in the race, but ultimately decided that it would be better just to include the top 75 participants in each race/gender category. This also makes the code more reasonable to run (time-wise).

ELO rankings were always initialized at 400, and the update factor was $K = 10$.
These were slightly tuned to make sure that the results seemed somewhat reasonable.

### Step 4: Finished!

Once the final ELO rankings were computed, I saved them to the `data/` directory. Some additional random tasks can be found in `r-code/01_random_tasks.R` and some data visualizations can be seen in `r-code/04_plots_and_such.R`.

## Data

- `uroy-results.csv` contains data on the top 10 UROY finishers for both male and female categories. It also includes each race they ran in 2024 and their placing the that race. This data was created by hand from [ultrarunning.com](https://ultrarunning.com/tag/2024uroy/).
- `race_results/` is a directory that contains `.csv` files for all the results of each of the 66 races considered in the analysis. These were webscraped using the code in `python-code` from various websites, including [ultrasignup](https://ultrasignup.com/default.aspx), [ITRA](https://itra.run/), and [ultrarunning.com](https://ultrarunning.com/)
- `non_csv_raw_files/` is a directory that contains two `.pdf` files with the results from the IAU 100k race. These PDFs were passed into ChatGPT to make the `.csv` files for these races.
- `race-data-map.csv` contains where the results were pulled from for each race. This was created by hand.
- `race-info.csv` contains data on each race, including time and location. It was created by hand.
- `all-results-w-dnfs.csv` was created via the process above, and includes the results of all runners in all races (not just the top 75). It treats DNFs as a last-place finish
- `all results-no-dnfs.csv` is the same as `all-results-w-dnfs.csv` except it removes all DNFs from the dataset. A filtered-down version of this dataset was used in the ranking process.
- `elo-results.csv` contains the results of the analysis and was created using the process above.

Please note that I do not own any rights to this data and it may contain errors.

## Other Notes

- Only ultra-distance events were considered (i.e., Eli Hemming's VK at Broken Arrow was not included)
- Check out some other webscrapers/reports:
  + [Towards Data Science Article](https://towardsdatascience.com/dfl-dnf-dns-60969b9e995d)
  + [X Acticle](https://x.com/digitalocean/status/1878913184796442673?mx=2) with the described tool [here](https://www.racetimeinsights.com/compare)
- Barkley Results [here](https://marathonhandbook.com/2024-barkley-marathons-results/ and times were gotten from http://runitfast.com/2024/03/22/ihor-verys-wins-2024-barkley-marathons-full-results/)
- Lululemon Results [here](https://marathonhandbook.com/lululemon-further-ultra-recap/)
- IAU result PDFs were downloaded [here](https://iau-ultramarathon.org/provisional-results-for-2024-iau-and-wma-100-km-world-championships.html) and then passed to ChatGPT to convert them to .csv files
- The Ultra Running Magazine website didn't have people who DNF'd; neither did the Chuckanut race
- Hannah Allgood had a name change in 2024, and was Hannah Osowski in all races prior to Javelina

## Contact

Please feel free to reach out if you have any suggestions!

