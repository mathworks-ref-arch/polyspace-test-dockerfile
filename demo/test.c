#include <pstunit.h>

extern int add(int a, int b);

PST_SIMPLE_TEST(test_sum_correct) {
    int actual_value = add(3,2);
    int expected_value = 5; 
    PST_VERIFY_EQ_INT(actual_value, expected_value);
}
