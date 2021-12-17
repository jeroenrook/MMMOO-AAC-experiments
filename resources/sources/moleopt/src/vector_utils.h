#ifndef VECTOR_UTILS_H
#define VECTOR_UTILS_H

#include "types.h"
#include "utils.h"

/* Vector addition and subtraction */

double_vector operator+(const double_vector& a, const double_vector& b);
double_vector operator-(const double_vector& a, const double_vector& b);

double_vector operator+(const double_vector& a, double scalar);
double_vector operator-(const double_vector& a, double scalar);

/* Scalar multiplication and division */

double_vector operator*(const double_vector& a, double scalar);
double_vector operator*(double scalar, const double_vector& a);
double_vector operator/(const double_vector& a, double divisor);
double_vector operator-(const double_vector& a);

/* General Utils */

double square_norm(const double_vector& vector);
double norm(const double_vector& vector);
double dot(const double_vector& a, const double_vector& b);
double angle(const double_vector& a, const double_vector& b);
double_vector normalize(const double_vector& vector);

bool dominates(const double_vector& a, const double_vector& b);
bool strictly_dominates(const double_vector& a, const double_vector& b);

void ensure_boundary(double_vector& vector, const double_vector& lower, const double_vector& upper);
void project_feasible_direction(double_vector& search_direction, const double_vector& current_position,
                           const double_vector& lower, const double_vector& upper);

double compute_improvement(const double_vector& obj_space, const double_vector& ref_point);

#endif
