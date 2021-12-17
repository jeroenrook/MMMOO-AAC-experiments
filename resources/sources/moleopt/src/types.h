#ifndef TYPES_H
#define TYPES_H

#include <vector>
#include <map>
#include <functional>

using namespace std;

typedef vector<double> double_vector;

struct evaluated_point {
  double_vector dec_space;
  double_vector obj_space;
  vector<double_vector> gradients;
  
  // bool operator<(const evaluated_point& rhs) const {
  //   int i = 0;
  //   int max_index = max(this->obj_space.size(), rhs.obj_space.size()) - 1;
  //   
  //   if (this->obj_space[i] == rhs.obj_space[i]) {
  //     if (i < max_index) i++;
  //   }
  //   
  //   return this->obj_space[i] < rhs.obj_space[i];
  // }
};

typedef map<double, evaluated_point> efficient_set;

typedef std::function<double_vector(double_vector)> optim_fn;
typedef std::function<vector<double_vector>(evaluated_point)> gradient_fn;
typedef std::function<evaluated_point(evaluated_point, double_vector, double)> corrector_fn;
typedef std::function<int(vector<efficient_set>, evaluated_point, double)> set_duplicated_fn;
typedef std::function<tuple<efficient_set, vector<evaluated_point>>(evaluated_point)> explore_set_fn;

#endif
