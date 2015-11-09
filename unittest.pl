#!/usr/bin/perl
BEGIN {
    my $cwd = $0;
    $cwd =~ s/\/[\w-\.]+$//;
    push( @INC, "$cwd/lib");
}
use strict;
use warnings;

my @list = <DATA>;
my $data = join('', @list);

sub unittest_activity_class{
    return $data;
}

__DATA__
package com.jfeat.apps.demo;

import android.os.Bundle;
import com.jfeat.plugin.flow.ActionFlow;
import com.jfeat.plugin.theme.BaseBackActivity;
import com.jfeat.plugin.theme.ToolbarWrapper;

public class UnitTestActivity extends BaseBackActivity {

    ActionFlow actionFlow = ActionFlow.create();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_unit_test);

        ToolbarWrapper wrapper = new ToolbarWrapper(this);
        wrapper.setTitle(R.string.title_activity_unit_test)
                .backNavigation();

        //actionFlow.registerActivity(R.id.action_desk_open, TestActivity.class);

        actionFlow.init(this, R.anim.next_in_right, R.anim.next_out_left);
    }
}
