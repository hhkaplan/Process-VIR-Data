%Input data
Data = importdata('/Volumes/TempFiles/Dawn_Test_Spec.txt');
xdata = Data(:,1);
ydata = Data(:,2);

%Subset data
i1 = find(xdata >= 4.8,1);
xdata_sub = xdata(i1:end-5,:);
ydata_sub = ydata(i1:end-5,:);

%Smooth, find peaks
ydata_sub_smooth = smooth(ydata_sub);
[~,locs_max] = findpeaks(ydata_sub);
[~,locs_min] = findpeaks(1-ydata_sub);

%Initial parameter (Temp, K) input into model
x0 = 200; 

%Least squares fit of planck function to the data
x = lsqcurvefit(@Lbb,x0,xdata_sub,ydata_sub_smooth);
x1 = lsqcurvefit(@Lbb,x0,xdata_sub,ydata_sub);
x2 = lsqcurvefit(@Lbb,x0,xdata,ydata);
x3 = lsqcurvefit(@Lbb,x0,xdata_sub(locs_max,:),ydata_sub(locs_max,:));
x4 = lsqcurvefit(@Lbb,x0,xdata_sub(locs_min,:),ydata_sub(locs_min,:));

%plot
plot(xdata,ydata,'-k'); hold on;
plot(xdata, Lbb(x, xdata));
plot(xdata, Lbb(x1, xdata));
plot(xdata, Lbb(x2, xdata));
plot(xdata, Lbb(x3, xdata));
plot(xdata, Lbb(x4, xdata));
plot(xdata_sub(locs_max,:),ydata_sub(locs_max,:),'r*')
plot(xdata_sub(locs_min,:),ydata_sub(locs_min,:),'b*')
axis([3.5,5.2,0,0.08]);
legend('data','smooth-sub','sub','full','upper','lower');

