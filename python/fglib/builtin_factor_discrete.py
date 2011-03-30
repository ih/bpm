def match_edge_LR(Ltile, Rtile):
	return Ltile.edge['R'] == Rtile.edge['L'] 

def match_edge_UD(Utile, Dtile):
	return Utile.edge['D'] == Dtile.edge['U'] 

def spacing_LR(Ltile, Rtile):
	return (Ltile.edge['U'], Rtile.edge['U']) != (1, 1)

def spacing_UD(Utile, Dtile):
	return (Utile.edge['L'], Dtile.edge['L']) != (1, 1)



def makef_eq(domain):
    return {'eq': lambda *args: reduce(lambda x, y: x.tid == y.tid, args)} 

def makef_noneq(domain):
    return {'neq': lambda *args: reduce(lambda x, y: x.tid != y.tid, args)} 

def makef_edgematch(domain):
    pass

pairwise_features = {
		'f2h0' : lambda x, y: (x, y) == (0,0),
		'f2h1' : lambda x, y: (x, y) == (0,1),
		'f2h2' : lambda x, y: (x, y) == (1,0),
		'f2h3' : lambda x, y: (x, y) == (1,1)
}

edge_match_lr_features = {
		'f2hlr' : lambda x, y: match_edge_LR(x, y),
		'f2hsp' : lambda x, y: spacing_LR(x, y),
}

edge_match_ud_features = {
		'f2vud' : lambda x, y: match_edge_UD(x, y),
		'f2vsp' : lambda x, y: spacing_UD(x, y),
}

single_features = {
		'f1s0' : lambda x: x == 0,
		'f1s1' : lambda x: x == 1
}

firstorder_features = {
		'eq' : lambda x, y: x == y
}

candidate_scopes_0 = {
		((0,0),) : single_features
}

candidate_scopes_1 = {
		((0,0), (1, 0)) : pairwise_features,
		((0,0),) : single_features
}

candidate_scopes_1_1 = {
		((0,0), (0, 1)) : pairwise_features,
}
candidate_scopes_2 = {
		((0,0), (1, 2)) : pairwise_features,
		((0,0), (3, 3)) : pairwise_features,
		((0,0), (3, -2)) : pairwise_features,
		((0,0),) : single_features
}

candidate_scopes_3 = {
		((0,0), (1, 0)) : pairwise_features,
		((0,0), (0, 1)) : pairwise_features,
		((0,0),) : single_features
}

candidate_scopes_3_1 = {
		((0,0), (1, 0)) : pairwise_features,
		((0,0), (0, 1)) : pairwise_features,
}

candidate_scopes_4 = {
		((0,0), (1, 0)) : pairwise_features,
		((0,0), (0, 1)) : pairwise_features,
		((0,0), (2, -2)) : pairwise_features,
		((0,0), (0, 2)) : pairwise_features,
		((0,0),) : single_features
}


candidate_scopes_road = {
		((0,0), (1, 0)) : edge_match_lr_features,
		((0,0), (0, 1)) : edge_match_ud_features,
}

theta_road = {
		'f2hlr' : 0.9736728180435188,
		'f2hsp' : 0.97692743100877266,
		'f2vud' : 0.96935378841020481,
		'f2vsp' : 0.98729909063133636,
}

theta_road2 = {
		'f2hlr' : 1.1,
		'f2hsp' : 1,
		'f2vud' : 1.1,
		'f2vsp' : 1,
}
