r"""
sage int_map.sage
mv int_map.sage.py imap.py
"""

from sage.functions.log import logb
from sage.all import Arrangements
from sage.all import prod, cos, pi, ceil

###############################################################################


def eval_func(func, variables_strings, shifted):
    r"""
    Evaluate the function, func, where the zeroth element starts at the nth
    element in the sequence.

    INPUT:

    - ``func`` -- SageFunc (default: ``); The integer mapping function.

    - ``variables_strings`` -- list (default: ``); A list of Sage variables.

    - ``shifted`` -- list (default: ``); A list of some integer.

    OUTPUT: The value of the function at point.
    """
    return func(**dict(zip(variables_strings, shifted)))


###############################################################################


def indices(dimensions, length):
    r"""
    The indices of a finite n-dimensional cube are the n length arrangements of
    n repeatitions of the integers 0 to the length of the dimension minus one.

    SEE:
        An arrangement of a multiset mset is an ordered selection without
    repetitions. It is represented by a list that contains only elements from
    mset, but maybe in a different order. Arrangements returns the
    combinatorial class of arrangements of the multiset mset that contain k
    elements.

    INPUT:

    - ``dimensions`` -- integer (default: ``); The number of dimensions.

    - ``length`` -- integer (default: ``); The length of a dimension.

    OUTPUT: A list of lists of every possible combination of coordinates inside
    a finite n-dimensional cube.

    """
    possible = dimensions*[i for i in range(length)]
    all_points = Arrangements(possible, dimensions).list()
    return all_points


###############################################################################


def p(a, n):
    r"""
    When the p function is evaluated over the period it produce a single 1
    followed by 2^(2^(a - 1) - 1) - 1 zeros then repeats.

    INPUT:

    - ``a`` -- integer (default: ``); The scale factor of the p function.

    - ``n`` -- variable (default: ``); Sage variable for iterating over
    the function.

    OUTPUT: A sage.expression of a product of cosines squared.


    .. SEEALSO::

        :func:`_calculate`
    """

    # Return sage product of cosines squared
    return prod(
        pow(cos(n*pi / pow(2, q)), 2)
        for q in range(1, pow(2, a - 1))
    )


###############################################################################


def imap(_array, _length, _dimension, _variables):
    r"""
    Applies the pfunc alogirthm into n dimensions. It all has the same form so
    the generalization is rather straight forward. Find all coordinates inside
    a finite n-dimensional cube. These will be the indices for the pfunc. At
    every coordinate the p function is summed together.

    SEE:
        indices
        ndpSum

    INPUT:
    - ``_array`` -- list (default:``); The initial starting
      sequence of integers.

    - ``_length`` -- integer (default:``); The length of initial_integers.

    - ``_dimension`` -- integer (default:``); The number of dimension.

    - ``_variables`` -- list (default:``); A list of variables to use in the
    function.

    OUTPUT: A sage.expression that represents the final_integers.

    """
    alpha = ceil(logb(logb(_length, 2) + 1, 2) + 1)
    function = 0
    all_points = indices(_dimension, _length)
    for point in all_points:
        function = ndpSum(
                            alpha,
                            _dimension,
                            _variables,
                            tuple(point),
                            function,
                            _array
                        )
    return function


def ndpSum(alpha, dimensions, variables, indices, addition, array):
    r"""
    Calculate the npdProduct at some coordinate, indices. Multiply
    the product by the array value at that coordinate then sum it all
    together and return the sum.

    SEE:
        npdProduct

    INPUT:
    - ``alpha`` -- integer (default:``); The pfunc scale factor.

    - ``dimensions`` -- integer (default:``); The number of dimensions.

    - ``variables`` -- list (default:``); List of sage variables.

    - ``addition`` -- integer (default:``); The value of the sum.

    - ``array`` -- list (default:``); The array of integers.

    OUTPUT: The sum of the array at some indices multiplied by the
    product at that same indices.
    """
    prod = ndpProduct(alpha, dimensions, variables, indices, 1, 0)
    addition += array[indices]*prod
    return addition


def ndpProduct(alpha, dimensions, variables, indices, product, _d):
    r"""
    Recursively calculates the p product at some index in indices.

    SEE:
        p

    INPUT:
    - ``alpha`` -- integer (default:``); The pfunc scale factor.

    - ``dimensions`` -- integer (default:``); The number of dimensions.

    - ``variables`` -- list (default:``); List of sage variables.

    - ``indices`` -- list (default:``); The list of indices.

    - ``product`` -- integer (default:``); The value of the product.

    - ``_d`` -- integer (default:``); Recursive counter.

    OUTPUT: The p product at some index in indices.
    """
    if _d >= dimensions:
        return product
    product *= p(alpha, variables[_d] - indices[_d])
    return ndpProduct(alpha, dimensions, variables, indices, product, _d + 1)
