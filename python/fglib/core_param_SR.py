from util_functional import concat
import util_vector as vec
from random import uniform

def get_thetas(sfwhn):
    return map(lambda (s, f, w, h, n): w, sfwhn)

def set_thetas(sfwhn, thetas):
    return map(lambda ((s, f, w, h, n), th): (s, f, th, h, n), zip(sfwhn, thetas))

def uniformInit(xs, min, max):
    return tuple(map(lambda x: uniform(min, max), xs))

# scorefx lambda fs, asn: 
# objfx lambda fs, asn: 
# fifx lambda fs, asn: 
# mcmc lambda fs, asn: 

def update_thetaSat(hard_sfwhn ,sfwhn, mcmcfx, scorefx, objfx, fifx, exp_objfx, makeFGfx, getasnfx, ex_elt_grids, syn_elt_grid, syn_dict_asn, stepsize=0.05):
    ex_factors_list = map( lambda ex: (getasnfx(ex), makeFGfx(hard_sfwhn, sfwhn, ex)[1]), ex_elt_grids)
    ex_factors_list = map(lambda (a, fs): map(lambda each_fs: (a, each_fs), fs), ex_factors_list)
    ex_factors_list = zip(*ex_factors_list)


    syn_hard_factors, syn_factors_list = makeFGfx(hard_sfwhn, sfwhn, syn_elt_grid)
    syn_factors = concat(syn_factors_list)

    curr_score = scorefx(syn_factors, syn_dict_asn)
    next_asn, next_score = mcmcfx(syn_hard_factors, syn_factors, syn_dict_asn)
    next_score = scorefx(syn_factors, next_asn)
    delta_score = curr_score - next_score

    next_obj = tuple(map(lambda fs: objfx(fs, next_asn), syn_factors_list))
    curr_obj = tuple(map(lambda fs: objfx(fs, syn_dict_asn), syn_factors_list))
    next_fi = tuple(map(lambda fs: fifx(fs, next_asn), syn_factors_list))
    curr_fi = tuple(map(lambda fs: fifx(fs, syn_dict_asn), syn_factors_list))

    exp_obj = tuple(map(lambda fs: exp_objfx(fs), ex_factors_list))

    grad = vec.sub(curr_fi, next_fi)
    objective_next = vec.neg(vec.cabs(vec.sub(exp_obj, next_obj)))
    objective_curr = vec.neg(vec.cabs(vec.sub(exp_obj, curr_obj)))
    delta_objtive = sum(vec.sub(objective_curr, objective_next))

    next_theta = get_thetas(sfwhn)

    for i in range(len(grad)):
        if delta_score < 0 and delta_objtive > 0:
            print "***************************************increase theta"
            next_theta[i] += stepsize * grad[i]
        elif delta_score > 0 and delta_objtive < 0:
            print "***************************************decrease theta"
            next_theta[i] -= stepsize * grad[i]

    new_param_features = set_thetas(sfwhn, next_theta)
    return next_asn, new_param_features, sum(objective_next)

def schedule_temp_linear(startTemp, endTemp = 1, repeat = 10, Nsamples = 5000):
    diff = int(float(Nsamples)/float(repeat))
    betas = map(lambda t:  (1-t)*startTemp + (t)*endTemp, map(lambda i: i/float(diff), range(1, diff+1)))
    return concat(map(lambda b: [b]*repeat, betas))


def grad_ascent(sfwhn, update, init_asn, Nsamples = 1000, init_step_size = 10):
    initial_theta = uniformInit(get_thetas(sfwhn), 0.8, 1.2)
    cur_sfwhn = set_thetas(sfwhn, initial_theta)
    new_sfwhn = cur_sfwhn
    new_objective = 0
    start_sfwhn = sfwhn
    step_size = init_step_size
    cur_asn = init_asn
    for i in range(Nsamples):
        #change stepsize of grad_ascent
        step_size = init_step_size/float(i+1)
        next_asn, new_sfwhn, new_objective = update(new_sfwhn, cur_asn, step_size)
        cur_sfwhn = new_sfwhn
        cur_asn = next_asn
        #print "new_sfwhn: ", new_sfwhn
        print "iteration %d" % i
        print "new_theta: ", get_thetas(new_sfwhn)
        print "initial_theta:", initial_theta
    return cur_sfwhn, new_objective


def easySR(hard_sfwhn, soft_sfwhn, mcmcfx, scorefx, objfx, fifx, exp_objfx, makeFGfx, getasnfx, ex_elt_grids, syn_elt_grid):
    update_theta_fx = lambda cur_sfwhn, cur_asn, step_size: update_thetaSat(hard_sfwhn, cur_sfwhn, mcmcfx, scorefx, objfx, fifx, exp_objfx, makeFGfx, getasnfx, ex_elt_grids, syn_elt_grid, cur_asn, step_size)
    res_sfwhn, result_objective = grad_ascent(soft_sfwhn, update_theta_fx, getasnfx(syn_elt_grid))

    return hard_sfwhn, res_sfwhn

