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

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('iteration', type=int, help='iteration')
    args = parser.parse_args()

    a = random.randint(0, 100)
    b = random.randint(-100, 100)
    quota = random.randint(-100, 100)
    answer = random.randint(1, 1024)
    goal = answer * a + b

    target_error = 1
    target_in_error = 5

    tuner = Tuner(the_algorithm, goal)
    nr_in_target = 0
#    print('quota\tscore\tgoal')
    for i in range(args.iteration):
        score = a * quota + b
        if abs(score - goal) / goal * 100 < target_error:
            nr_in_target += 1
        else:
            nr_in_target = 0
        if nr_in_target == target_in_error:
#            print('reached to the target accuracy in %d iteration' % i)
            break
        quota = tuner.get_next_quota(score)
#        print('%10.2f\t%10.2f\t%10.2f' % (quota, score, goal))
        print(i, score / goal, 1)
    if i == args.iteration - 1:
        print('failed')
        print(i, a, b)

if __name__ == '__main__':
    main()
