def tuning_model(df, learning_rate, max_depth, n_estimators, objective, train_frac = 0.3):
    
    # data
    #del df['position']
    gss = GroupShuffleSplit(test_size= train_frac, n_splits=1, random_state = 7).split(df, groups=df['srch_id'])

    X_train_inds, X_test_inds = next(gss)
    train_data= df.iloc[X_train_inds]
    test_data= df.iloc[X_test_inds]
    properties = test_data['prop_id']
    del train_data['prop_id']
    del test_data['prop_id']
    #del df['prop_id']


    X_train = train_data.loc[:, ~train_data.columns.isin(['srch_id','score'])]
    #X_train = train_data.loc[:, ~train_data.columns.isin(['srch_id'])]

    y_train = train_data.loc[:, train_data.columns.isin(['score'])]

    groups = train_data.groupby('srch_id').size().to_frame('size')['size'].to_numpy()


    #We need to keep the id for later predictions
    X_test = test_data.loc[:, ~test_data.columns.isin(['score'])]
    y_test = test_data.loc[:, test_data.columns.isin(['score'])]


    model = xgb.XGBRanker(  
    tree_method='hist',
    booster='gbtree',
    objective=objective,
    random_state=42,    
    learning_rate=learning_rate,
    colsample_bytree=0.9,  
    max_depth=max_depth, 
    n_estimators=n_estimators, 
    subsample=0.75 
    )
    
    model.fit(X_train, y_train, group=groups, verbose=True)
    

    predictions = (X_test.groupby('srch_id').apply(lambda x: predict(model, x)))
    output = pd.DataFrame()
    output["srch_id"] = test_data["srch_id"]
    output["prop_id"] = properties

    # Add scores
    pred_scores_list = []

    for i in predictions:
        for j in i:
            pred_scores_list.append(j)      

    output["pred_scores"] = pred_scores_list
    
    out = output.groupby('srch_id').apply(pd.DataFrame.sort_values, 'pred_scores', ascending=False)
    del out["pred_scores"]
    #out.to_csv('../data/submission_cate.csv', index=False)
    
    return NDCG(out, df, path_idcg = "idcg.csv")
    
    