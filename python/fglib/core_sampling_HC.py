from core_sampling_AISp import AISp

def make_HC_fseq(curr_scoring_log, added_scoring_log, betas):
    return map(lambda b: lambda asn: curr_scoring_log(asn) + added_scoring_log(asn)*(b), betas)


def HC(particles_weights, tree_factors, added_factors, scoring_prototypefx, betas, trans_kernel, proposal_fx, resample_interval, trans_iter):

    scoring_curr = map(lambda i: lambda asn: scoring_prototypefx(tree_factors + added_factors[0:i], asn), range(len(added_factors)))
    scoring_added = map(lambda f: lambda asn: scoring_prototypefx([f], asn), added_factors)
    scoring_pair = zip(scoring_curr, scoring_added)
    fseqs = map(lambda (fc, fa): make_HC_fseq(fc, fa, betas), scoring_pair)

    particles, weights = zip(*particles_weights)

    Tseqs = map(lambda fseq: map(lambda fi: lambda asn: trans_kernel(fseq[-1], asn, proposal_fx, trans_iter), fseq), fseqs)

    for i in range(len(fseqs)):
        particles_weights = AISp(fseqs[i], Tseqs[i], particles)
        particles, weights = zip(*particles_weights)
    return particles_weights

