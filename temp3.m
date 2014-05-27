load data


    f_x = @(x_check)differential_eqs_lk_perm(t,x_check,y,ps,0); %had 0 instead of t before
    f_y = @(y_check)differential_eqs_lk_perm(t,x,y_check,ps,0);
    g_x = @(x_check)algebraic_eqs_lk_perm(t,x_check,y,ps,0);
    g_y = @(y_check)algebraic_eqs_lk_perm(t,x,y_check,ps,0);
    [fcheck,df_dx0,df_dy0] = f_y(y);
    [gcheck,dg_dx0,dg_dy0] = g_x(x);
    [gcheck2,dg_dx0,dg_dy0] = g_y(y);
  keyboard
    checkDerivatives(g_y, dg_dy0,y);
    checkDerivatives(g_x, dg_dx0,x);
    checkDerivatives(f_x, df_dx0,x);
    checkDerivatives(f_y, df_dy0,y);
[max_real_evals_full,num_pos_evals]=stability_check(df_dx0,df_dy0,dg_dx0,dg_dy0,ps);