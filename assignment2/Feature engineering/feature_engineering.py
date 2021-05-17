import pandas as pd
import numpy as np
import random

### reading and sampling the data

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
    chosen_k = int(len(srch_ids) * frac)
    # sample ids
    chosen_ids = random.sample(list(srch_ids), k = chosen_k)
    # filter the df to only have sampled ids
    return df[df['srch_id'].isin(chosen_ids)]

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
    del df['date_time']

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

def add_historical_booking_click(df):
    """
    creates a column with the percentage of the prop_id booked/clicked rate overall
    """
    # there are more prop_id in the test data than in train. 
    # Maybe we could still use this but would need to impute
    # with the most common value (or something else)
    
    historical = df.groupby("prop_id")[["click_bool", "booking_bool"]].mean().reset_index()
    historical.columns = [historical.columns[0]] + [x + "_rate" for x in historical.columns[1:]]
    df = pd.merge(df, historical, on="prop_id")
    df.sort_values("srch_id", inplace = True)
    return df

def join_historical_data(df, path = "hist_click_book.csv"):
    """
    joins historical data according to prop_id. 
    path - location of historical data csv file
    
    """
    to_join = pd.read_csv(path)
    joined = pd.merge(df, to_join, on="prop_id")
    return joined.sort_values("srch_id")

def create_comp_rate_mode(df, fillna_ = -100):
    """
    creates a column with the mode of comp_rate columns and fills the rest with -100 (default)
    """
    #subset comp_rate
    comp_rate_cols = [col for col in df.columns if col.endswith("_rate")]
    df["comp_rate_mode"] = df[comp_rate_cols].mode(axis = 1, dropna = True)[0]
    df_sample["comp_rate_mode"].fillna(fillna_ , inplace = True)

def create_comp_inv_mode(df, fillna_ = -100):
    """
    creates a column with the mode of comp_inv columns and fills the rest with -100 (default)
    """
    comp_inv = [col for col in df.columns if col.endswith("_inv")]
    df["comp_inv_mode"] = df[comp_inv].mode(axis = 1, dropna = True)[0]
    df["comp_inv_mode"].fillna(fillna_ , inplace = True)

def normalize_features(df_mod, normalizing_var, column):
    # df_mod = dataframe
    # normalizing_var = variable that will be used for normalizing
    # column = variable that will be normalized

    methods = ["mean", "std"]

    df = df_mod.groupby(normalizing_var).agg({column: methods})

    df.columns = df.columns.droplevel()
    col = {}
    for method in methods:
        col[method] = column + "_" + method

    df.rename(columns=col, inplace=True)
    df_merge = df_mod.merge(df.reset_index(), on=normalizing_var)
    df_merge[column + "_norm_by_" + normalizing_var] = (
        df_merge[column] - df_merge[column + "_mean"]
    ) / df_merge[column + "_std"]
    df_merge = df_merge.drop(labels=[col["mean"], col["std"]], axis=1)

    return df_merge    
    
## other ----------------------------------

def remove_cols(df, cols = ["position", "prop_id"]):
    df.drop(cols, axis=1, inplace=True)

def remove_positions(df, positions = [5, 11, 17, 23]):
    """
    removes hotels with specified positions 
    (based on the fact that hotels in those positions were not as booked)
    """
    df = df[df["position"].isin(positions) == False]

def add_score(df):
    """
    adds 'score' column to the df: 5 for booked, 1 for clicked
    """
    score = []
    for book, click in zip(df.booking_bool, df.click_bool):
        if book == 1:
            score.append(5)
            continue
        if click == 1:
            score.append(1)
            continue
        else:
            score.append(0)
    df["score"] = score
    del df['booking_bool']
    del df['click_bool']

def onehot(df, cols):
    """ 
    returns a df with one-hot encoded columns (cols)
    """
    
    return pd.get_dummies(df, columns=cols)


### Feature engineering function -----------

def feature_engineering_train(df):
    
    extract_time(df)
    remove_missing_values(df)
    replace_missing_values(df)
    new_historical_price(df)
    add_price_position(df)
    df = average_numerical_features(df)
    df = add_historical_booking_click(df)
    add_score(df)
    #remove_cols(df)
    return df

def feature_engineering_test(df):
    
    extract_time(df)
    remove_missing_values(df)
    replace_missing_values(df)
    new_historical_price(df)
    add_price_position(df)
    df = average_numerical_features(df)
    return df
    
