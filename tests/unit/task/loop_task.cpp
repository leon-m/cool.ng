/*
 * Copyright (c) 2017 Leon Mlakar.
 * Copyright (c) 2017 Digiverse d.o.o.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. The
 * license should be included in the source distribution of the Software;
 * if not, you may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * The above copyright notice and licensing terms shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#include <iostream>
#include <typeinfo>
#include <memory>
#include <stack>
#include <functional>
#include <atomic>
#include <mutex>
#include <thread>
#include <chrono>
#include <condition_variable>
#include <exception>

#define BOOST_TEST_MODULE LoopTask
#include <boost/test/unit_test.hpp>

#include "cool/ng/async.h"

using ms = std::chrono::milliseconds;

BOOST_AUTO_TEST_SUITE(loop_task)


class my_runner : public cool::ng::async::runner
{
 public:
  void inc() { ++counter; }
  void clear() { counter = 0; }
  int counter = 0;
};

BOOST_AUTO_TEST_CASE(void_with_body)
{
  auto runner_1 = std::make_shared<my_runner>();
  auto runner_2 = std::make_shared<my_runner>();
  auto runner_3 = std::make_shared<my_runner>();

  std::mutex m;
  std::condition_variable cv;
  std::atomic<int> counter;
  counter = 0;

  auto wakeup = cool::ng::async::factory::create(
      runner_3
    , [&m, &cv, &counter] (const std::shared_ptr<my_runner>& r) -> void
      {
        counter = 1;
        std::unique_lock<std::mutex> l(m);
        cv.notify_one();
      }
  );
  auto body = cool::ng::async::factory::create(
      runner_2
    , [] (const std::shared_ptr<my_runner>& r) -> void
      {
       r->inc();
      }
  );

  {
    auto predicate = cool::ng::async::factory::create(
        runner_1
      , [] (const std::shared_ptr<my_runner>& r) -> bool
        {
          r->inc();
          return false;
        }
    );

    auto task = cool::ng::async::factory::sequence(cool::ng::async::factory::loop(predicate, body), wakeup);

    std::unique_lock<std::mutex> l(m);
    task.run();
    cv.wait_for(l, ms(100), [&counter] { return counter != 0; });
    BOOST_CHECK_EQUAL(1, runner_1->counter);
    BOOST_CHECK_EQUAL(0, runner_2->counter);
  }

  runner_1->clear();
  runner_2->clear();
  counter = 0;

  {
    auto predicate = cool::ng::async::factory::create(
        runner_1
      , [] (const std::shared_ptr<my_runner>& r) -> bool
        {
          r->inc();
          return r->counter < 100;
      }
    );

    auto task = cool::ng::async::factory::sequence(cool::ng::async::factory::loop(predicate, body), wakeup);

    std::unique_lock<std::mutex> l(m);
    task.run();
    cv.wait_for(l, ms(100), [&counter] { return counter != 0; });
    BOOST_CHECK_EQUAL(100, runner_1->counter);
    BOOST_CHECK_EQUAL(99, runner_2->counter);
  }
}

BOOST_AUTO_TEST_CASE(int_with_body)
{
  auto runner_1 = std::make_shared<my_runner>();
  auto runner_2 = std::make_shared<my_runner>();
  auto runner_3 = std::make_shared<my_runner>();

  std::mutex m;
  std::condition_variable cv;
  int counter = -1;
  bool done = false;

  auto wakeup = cool::ng::async::factory::create(
      runner_3
    , [&m, &cv, &counter, &done] (const std::shared_ptr<my_runner>& r, int input) -> void
      {
        counter = input;
        done = true;
        std::unique_lock<std::mutex> l(m);
        cv.notify_one();
      }
  );
  auto body = cool::ng::async::factory::create(
      runner_2
    , [] (const std::shared_ptr<my_runner>& r, int input) -> int
      {
        r->inc();
        return input + 1;
      }
  );

  {
    auto predicate = cool::ng::async::factory::create(
        runner_1
      , [] (const std::shared_ptr<my_runner>& r, int input) -> bool
        {
          r->inc();
          return false;
        }
    );

    auto task = cool::ng::async::factory::sequence(cool::ng::async::factory::loop(predicate, body), wakeup);

    std::unique_lock<std::mutex> l(m);
    task.run(0);
    cv.wait_for(l, ms(100), [&done] { return done; });
    BOOST_CHECK_EQUAL(1, runner_1->counter);
    BOOST_CHECK_EQUAL(0, runner_2->counter);
    BOOST_CHECK_EQUAL(0, counter);
  }

  runner_1->clear();
  runner_2->clear();
  counter = -1;
  done = false;

  {
    auto predicate = cool::ng::async::factory::create(
        runner_1
      , [] (const std::shared_ptr<my_runner>& r, int input) -> bool
      {
        r->inc();
        return input < 100;
      }
      );

    auto task = cool::ng::async::factory::sequence(cool::ng::async::factory::loop(predicate, body), wakeup);

    std::unique_lock<std::mutex> l(m);
    task.run(0);
    cv.wait_for(l, ms(100), [&done] { return done; });
    BOOST_CHECK_EQUAL(101, runner_1->counter);
    BOOST_CHECK_EQUAL(100, runner_2->counter);
    BOOST_CHECK_EQUAL(100, counter);
  }
}

BOOST_AUTO_TEST_CASE(no_body)
{
  auto runner_1 = std::make_shared<my_runner>();
  auto runner_3 = std::make_shared<my_runner>();

  std::mutex m;
  std::condition_variable cv;
  bool done = false;

  auto wakeup = cool::ng::async::factory::create(
      runner_3
    , [&m, &cv, &done] (const std::shared_ptr<my_runner>& r) -> void
      {
        done = true;
        std::unique_lock<std::mutex> l(m);
        cv.notify_one();
      }
  );

  {
    auto predicate = cool::ng::async::factory::create(
        runner_1
      , [] (const std::shared_ptr<my_runner>& r) -> bool
        {
          r->inc();
          return false;
        }
    );

    auto task = cool::ng::async::factory::sequence(cool::ng::async::factory::loop(predicate), wakeup);

    std::unique_lock<std::mutex> l(m);
    task.run();
    cv.wait_for(l, ms(100), [&done] { return done; });
    BOOST_CHECK_EQUAL(1, runner_1->counter);
  }

  runner_1->clear();
  done = false;

  {
    auto predicate = cool::ng::async::factory::create(
        runner_1
      , [] (const std::shared_ptr<my_runner>& r) -> bool
      {
        r->inc();
        return r->counter < 100;
      }
      );

    auto task = cool::ng::async::factory::sequence(cool::ng::async::factory::loop(predicate), wakeup);

    std::unique_lock<std::mutex> l(m);
    task.run();
    cv.wait_for(l, ms(100), [&done] { return done; });
    BOOST_CHECK_EQUAL(100, runner_1->counter);
  }
}

BOOST_AUTO_TEST_SUITE_END()
