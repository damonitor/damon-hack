#!/usr/bin/env python3

class Tuner:
    past_quotas = None
    past_scores = None
    algorithm = None
    goal = None

    def __init__(self, algorithm, goal):
        self.past_quotas = []
        self.past_scores = []
        algorithm = algorithm
        self.goal = goal

    def get_next_quota(self, current_score):
        if len(past_quotas) == 0:
            self.past_scores.append(current_score)
            self.past_quotas.append(1)
            return 1
        self.past_scores.append(current_score)
        next_quota = algotithm(self.goal, self.past_scores, self.past_quotas)
        self.past_quotas.append(next_quota)
        return next_quota

def the_algorithm(goal, past_scores, past_quotas):
    return max(past_quotas[-1] * ((goal - past_scores[-1]) / goal + 1), 1)


def main():
    return

if __name__ == '__main__':
    main()
