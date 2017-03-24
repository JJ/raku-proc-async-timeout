use v6.c;

class X::Proc::Async::Timeout is Exception is export {
    has $.command;
    has $.seconds;
    method message {
        "⟨$.command⟩ timed out after $.seconds seconds.";
    }
}

class Proc::Async::Timeout is Proc::Async is export {
    method start(Numeric :$timeout, |c --> Promise:D) {
        state &parent-start-method = nextcallee;
        start {
            await my $outer-p = Promise.anyof(my $p = parent-start-method(self, |c), Promise.at(now + $timeout));
            if $p.status != Kept {
                self.kill;
                fail X::Proc::Async::Timeout.new(command => self.path, seconds => $timeout);
            }
        }
    }
}
