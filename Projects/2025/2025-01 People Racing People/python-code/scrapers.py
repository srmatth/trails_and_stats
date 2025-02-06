from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import pandas as pd

def ultrasignup_scraper(url):
    """
    Scrape the Ultrasignup website
    """
    # Set up Selenium WebDriver (e.g., using Chrome)
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")  # Run in headless mode (no UI)
    
    # Initiate the driver
    driver = webdriver.Chrome(options=options)

    # Open the URL and wait for the table to load
    driver.get(url)
    wait = WebDriverWait(driver, 20)  # Timeout after 20 seconds
    table_element = wait.until(EC.presence_of_element_located((By.ID, "list")))

    # Find the table element and extract the data
    table = driver.find_element(By.ID, "list")

    rows = table.find_elements(By.TAG_NAME, "tr")
    data = []
    for row in rows:
        cols = row.find_elements(By.TAG_NAME, "td")
        data.append([col.text for col in cols])

    # save the data to a pandas dataframe and close the driver
    df = pd.DataFrame(data) 
    driver.quit()

    # Clean the dataframe
    df = df.iloc[2:, 1:10]
    df.columns = ['Position', 'First Name', 'Last Name', 'City', 'State', 'Age', 'Gender', 'Division Place', 'Time']

    return df

def itra_scraper(url):
    """
    Scrape the ITRA website
    """
    # Set up Selenium WebDriver (e.g., using Chrome)
    options = webdriver.ChromeOptions()
    # options.add_argument("--headless")  # Run in headless mode (no UI)
    
    # Initiate the driver
    driver = webdriver.Chrome(options=options)

    # Open the URL and wait for the table to load
    driver.get(url)
    wait = WebDriverWait(driver, 20)  # Timeout after 20 seconds
    table_element = wait.until(EC.presence_of_element_located((By.ID, "RunnerRaceResults")))

    # Find the table element and extract the data
    table = driver.find_element(By.ID, "RunnerRaceResults")

    tbody = table.find_element(By.TAG_NAME, "tbody")
    rows = tbody.find_elements(By.TAG_NAME, "tr")

    # rows = table.find_elements(By.TAG_NAME, "tr")
    data = []
    for idx, row in enumerate(rows):
        cols = row.find_elements(By.TAG_NAME, "td")
        row_data = [col.text.strip() for col in cols]

        if idx == 0 and len(row_data) > 5:
            row_data[3] = row_data[4]  # Move 4th column (index 3) to 3rd column (index 2)
            row_data[4] = row_data[5]  # Move 5th column (index 4) to 4th column (index 3)
            row_data[5] = row_data[6] 
        
        data.append(row_data[:6])

    # save the data to a pandas dataframe and close the driver
    headers = ["Place", "Runner", "Time", "Age", "Gender", "Country"]
    df = pd.DataFrame(data, columns=headers) 
    driver.quit()

    return df

def runsignup_scraper(url):
    """
    Scrape the RunSignup website
    """
    # Set up Selenium WebDriver (e.g., using Chrome)
    options = webdriver.ChromeOptions()
    # options.add_argument("--headless")  # Run in headless mode (no UI)
    
    # Initiate the driver
    driver = webdriver.Chrome(options=options)

    # Open the URL and wait for the table to load
    driver.get(url)
    wait = WebDriverWait(driver, 20)  # Timeout after 20 seconds
    table_element = wait.until(EC.presence_of_element_located((By.ID, "resultsTable")))
    table_element = wait.until(EC.presence_of_element_located((By.TAG_NAME, "thead")))

    # Find the table element and extract the data
    table = driver.find_element(By.ID, "resultsTable")
    thead = table.find_element(By.TAG_NAME, "thead")
    headers = [header.text for header in thead.find_elements(By.TAG_NAME, "th")]

    tbody = table.find_element(By.TAG_NAME, "tbody")
    rows = tbody.find_elements(By.TAG_NAME, "tr")
    data = []
    for row in rows:
        cols = row.find_elements(By.TAG_NAME, "td")
        row_data = [col.text.strip() for col in cols]
        data.append(row_data)

    # save the data to a pandas dataframe and close the driver
    df = pd.DataFrame(data) 
    driver.quit()

    # Clean the dataframe
    to_keep = ['Place', "Bib", "Name", "Gender", "Age", "City", "State", "Country", "Clock Time", "Chip Time", "Pace"]
    df.columns = headers

    df_filtered = df.filter(items=to_keep)

    if "Name" in df_filtered.columns:
        df_filtered["Name"] = df_filtered["Name"].str.replace(r'^[A-Z]\n', '', regex=True).str.replace(r'\n', ' ', regex=True)
    if "Clock Time" in df_filtered.columns:
        df_filtered["Clock Time"] = df_filtered["Clock Time"].str.replace(r'\n.*', '', regex=True)

    return df_filtered

def pacific_multisports_scraper(url):
    """
    Scrape the Pacific Multisports website
    """
    # Set up Selenium WebDriver (e.g., using Chrome)
    options = webdriver.ChromeOptions()
    # options.add_argument("--headless")  # Run in headless mode (no UI)
    
    # Initiate the driver
    driver = webdriver.Chrome(options=options)

    # Open the URL and wait for the table to load
    driver.get(url)
    wait = WebDriverWait(driver, 20)  # Timeout after 20 seconds
    table_element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, "LastRecordLine")))

    # Find the table element and extract the data
    table = driver.find_element(By.CLASS_NAME, "MainTable")
    tbody = table.find_elements(By.TAG_NAME, "tbody")
    tbody = tbody[1]
    rows = tbody.find_elements(By.TAG_NAME, "tr")

    data = []
    for row in rows:
        cols = row.find_elements(By.TAG_NAME, "td")
        row_data = [col.text.strip() for col in cols]
        data.append(row_data[1:7])

    # save the data to a pandas dataframe and close the driver
    df = pd.DataFrame(data) 
    driver.quit()

    df.columns = ["Place", "Bib", "Name", "AG", "State/Province", "ChipTime"]

    return df

def ultrarunning_scraper(url):
    """
    Scrape the UltraRunning website
    """
    # Set up Selenium WebDriver (e.g., using Chrome)
    options = webdriver.ChromeOptions()
    # options.add_argument("--headless")  # Run in headless mode (no UI)
    
    # Initiate the driver
    driver = webdriver.Chrome(options=options)

    # Open the URL and wait for the table to load
    driver.get(url)
    wait = WebDriverWait(driver, 20)  # Timeout after 20 seconds
    table_element = wait.until(EC.presence_of_element_located((By.CLASS_NAME, "table-responsive")))

    # Find the table element and extract the data
    table = driver.find_element(By.CLASS_NAME, "table-responsive")
    tbody = table.find_element(By.TAG_NAME, "tbody")
    rows = tbody.find_elements(By.TAG_NAME, "tr")

    data = []
    for row in rows:
        cols = row.find_elements(By.TAG_NAME, "td")
        row_data = [col.text.strip() for col in cols]
        data.append(row_data)

    # save the data to a pandas dataframe and close the driver
    df = pd.DataFrame(data) 
    driver.quit()

    df.columns = ["OP", "DP", "Name", "Time"]
    df[["Name", "Gender", "AG"]] = df["Name"].str.split("\n", expand=True)

    return df
