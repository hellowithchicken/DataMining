import pandas as pd
import random

### reading and sampling the data

def read_file(path):
    """
    reads the file in pandas df and converts the date_time column to datetime type
    """
    df = pd.read_csv(path)
    df['date_time'] = pd.to_datetime(df['date_time'])
    return df

def sample_on_srch_id(df, frac = 0.1):
    """
    samples the dataframe based on the fraction of srach_id
    """
    # get unique srch_ids
    srch_ids = np.unique(df.srch_id)
    # calculate how many ids to return
    chosen_k = int(len(srch_id) * frac)
    # sample ids
    chosen_ids = random.sample(srch_ids, k = chosen_k)
    # filter the df to only have sampled ids
    return df[df['srch_id'].isin(srch_ids)]

### Feature Engineering --------------------------

## missing data ----------------------------------

def remove_missing_values(df):
    """
    removes columns with more than 50 percent missing data
    """
    missing_values = df.isna().mean().round(4) * 100
    missing_values = pd.DataFrame(missing_values).reset_index()
    missing_values.columns = ["column", "missing"]
    # filter where there are missing values
    missing_values.query("missing > 50", inplace=True)  # remove columns with more than 50 % of missing values
    missing_values.sort_values("missing", inplace=True)
    #print(missing_values)
    df.drop(missing_values.column, axis=1, inplace=True)

def replace_missing_values(df):
    """
    imputes missing values with -1
    """
    df.fillna(value=-1, inplace=True) 

## new features ----------------------------------

def extract_time(df):
    """ 
    month, week, day of the week and hour of search
    """
    df_datetime = pd.DatetimeIndex(df.date_time)
    df["month"] = df_datetime.month
    df["week"] = df_datetime.week
    df["day"] = df_datetime.dayofweek + 1
    df["hour"] = df_datetime.hour

def new_historical_price(df):
    """
    'unlogs' prop_log_historical_price column
    """
    df["prop_historical_price"] = (np.e ** df.prop_log_historical_price).replace(1.0, 0)
    df.drop("prop_log_historical_price", axis=1, inplace=True)

def add_price_position(df, rank_type = "dense"):
    """
    adds hotel price position ("price_position") inside "srch_id" column
    """
    ranks = df.groupby('srch_id')['price_usd'].rank(ascending=True, method = rank_type)
    df["price_position"] = ranks


def average_numerical_features(df, group_by = ["prop_id"], columns = ["prop_starrating", "prop_review_score", "prop_location_score1", "prop_location_score2"]):
    """
    adds mean, median and standard deviation per prop_id (default) 
    for columns that are related to property (default)
    """
    # caulcate means and rename columns
    means = df.groupby(group_by)[columns].mean().reset_index()
    means.columns = [means.columns[0]] + [x + "_mean" for x in means.columns[1:]]
    # caulcate median and rename columns
    medians = df.groupby(group_by)[columns].median().reset_index()
    medians.columns = [medians.columns[0]] + [x + "_median" for x in medians.columns[1:]]
    # caulcate means and rename columns
    stds = df.groupby(group_by)[columns].std().reset_index()
    stds.columns = [stds.columns[0]] + [x + "_std" for x in stds.columns[1:]]
    ## attach aggregated data to the df
    df = pd.merge(df, means, on=group_by)
    df = pd.merge(df, medians, on=group_by)
    df = pd.merge(df, stds, on=group_by)
    return df

    
    
## other ----------------------------------

def remove_positions(df, positions = [5, 11, 17, 23]):
    """
    removes hotels with specified positions 
    (based on the fact that hotels in those positions were not as booked)
    """
    df = df[df["position"].isin(positions) == False]
    
### Feature engineering function -----------

def feature_engineering(df):
    extract_time(df)
    remove_missing_values(df)
    replace_missing_values(df)
    new_historical_price(df)
    add_price_position(df)
    average_numerical_features(df)

    

