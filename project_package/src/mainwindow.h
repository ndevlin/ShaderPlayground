// Created by Adam Mally, modified by Nathan Devlin

#ifndef MAINWINDOW_H
// Created by Adam Mally, modified by Nathan Devlin

#define MAINWINDOW_H

#include <QMainWindow>
#include <QGraphicsScene>
#include "shadercontrols.h"


namespace Ui
{
    class MainWindow;
}


class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    void closeEvent(QCloseEvent *e);

private slots:
    void on_actionQuit_triggered();

private:
    Ui::MainWindow *ui;

    ShaderControls *shaderControls;

};


#endif // MAINWINDOW_H
