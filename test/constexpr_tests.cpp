#include <catch2/catch_test_macros.hpp>

#include <best_practices_starter/sample_library.hpp>
TEST_CASE("Factorials are computed with constexpr", "[factorial]")
{
	#ifdef __APPLE__
	  STATIC_REQUIRE(factorial_constexpr(0) == 1); // cppcheck-suppress knownConditionTrueFalse
	  STATIC_REQUIRE(factorial_constexpr(1) == 1); // cppcheck-suppress knownConditionTrueFalse
	  STATIC_REQUIRE(factorial_constexpr(2) == 2); // cppcheck-suppress knownConditionTrueFalse
	  STATIC_REQUIRE(factorial_constexpr(3) == 6); // cppcheck-suppress knownConditionTrueFalse
	  STATIC_REQUIRE(factorial_constexpr(10) == 3628800); // cppcheck-suppress knownConditionTrueFalse	
	#else
	  STATIC_REQUIRE(factorial_constexpr(0) == 1);
	  STATIC_REQUIRE(factorial_constexpr(1) == 1);
	  STATIC_REQUIRE(factorial_constexpr(2) == 2);
	  STATIC_REQUIRE(factorial_constexpr(3) == 6);
	  STATIC_REQUIRE(factorial_constexpr(10) == 3628800);
	#endif

}
