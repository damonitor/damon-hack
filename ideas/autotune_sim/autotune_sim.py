#!/usr/bin/env python3

import argparse
import random

class Tuner:
    past_quotas = None
    past_scores = None
    algorithm = None
    goal = None

    def __init__(self, algorithm, goal):
        self.past_quotas = []
        self.past_scores = []
        self.algorithm = algorithm
        self.goal = goal

    def get_next_quota(self, current_score):
        if len(self.past_quotas) == 0:
            self.past_scores.append(current_score)
            self.past_quotas.append(1)
            return 1
        self.past_scores.append(current_score)
        next_quota = self.algorithm(self.goal, self.past_scores, self.past_quotas)
        self.past_quotas.append(next_quota)
        return next_quota

def the_algorithm(goal, past_scores, past_quotas):
    return max(past_quotas[-1] * ((goal - past_scores[-1]) / goal + 1), 1)

def score_of(input_, a, b, max_error_percent):
    score_wo_err = input_ * a + b
    max_error_half = int(score_wo_err * max_error_percent / 100 / 2)
    return score_wo_err + random.randint(max_error_half * -1 , max_error_half)

def run_simulation():
    '''Returns number of steps to converge'''
    max_steps = 1000
    print_for_plot = False
    a = random.randint(0, 100)
    b = random.randint(-100, 100)
    quota = random.randint(0, 1024)
    answer = random.randint(1, 1024)
    goal = score_of(answer, a, b, 0)

    target_error = 1
    target_in_error = 5

    tuner = Tuner(the_algorithm, goal)
    nr_in_target = 0
    for i in range(max_steps):
        score = score_of(quota, a, b, 0.5)
        if abs(score - goal) / goal * 100 < target_error:
            nr_in_target += 1
        else:
            nr_in_target = 0
        if nr_in_target == target_in_error:
            break
        quota = tuner.get_next_quota(score)
        if print_for_plot:
            print(i, score / goal)
    if i == max_steps - 1:
        return -1
    return i

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('nr_runs', type=int, help='number of runs')
    args = parser.parse_args()

    success_nr_steps = []
    nr_failures = 0
    for i in range(args.nr_runs):
        nr_steps = run_simulation()
        if nr_steps == -1:
            nr_failures += 1
        else:
            success_nr_steps.append(nr_steps)
    print('failed %d times' % nr_failures)
    print('nr steps to success')
    print('avg %d' % (sum(success_nr_steps) / len(success_nr_steps)))
    success_nr_steps.sort()
    print('min/mean/max: %d %d %d' % (success_nr_steps[0],
        success_nr_steps[int(len(success_nr_steps) / 2)],
        success_nr_steps[-1]))

if __name__ == '__main__':
    main()
