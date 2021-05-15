def NDCG(predictions, df, path_idcg = "idcg.csv"):
    """
    takes predicted positions and calulates average ndcg.
    predictions - dataframe must have "srch_id" and "prop_id" ordered by relevance (inside "srch_id") (basically Lotte's model "out" dataframe)
    df - training dataset (must contain "srch_id", "prop_id", "score")
    path_idcg - path to idcg scores per "srch_id"
    """
    # reset index 
    predictions.reset_index(drop = True, inplace = True)
    # add position + 1
    predictions["position"] = predictions.groupby(by = ['srch_id']).cumcount()+2
    # attach scores to predictions
    predictions = pd.merge(predictions, df[["srch_id", "prop_id", "score"]], on = ["srch_id", "prop_id"])
    # calculate dcg
    predictions["numerator"] = np.power(2, predictions["score"]) - 1
    predictions["denominator"] = np.log2(predictions["position"])
    predictions["intermediate_dcg"] = predictions["numerator"]/predictions["denominator"]
    dcg = predictions.groupby("srch_id")["intermediate_dcg"].sum().reset_index()
    dcg.columns = ["scrh_id", "DCG"]
    # read idcg
    idcg = pd.read_csv(path_idcg)
    # attach idcg to dcg
    joined = pd.merge(dcg, idcg, on = "scrh_id")
    # calculate NDCG
    joined["NDCG"] = joined["DCG"]/joined["iDCG"]
    # calculate mean NDCG
    return joined["NDCG"].mean()

