package mop;

import java.io.File;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.io.PrintWriter;
import java.io.IOException;
import org.aspectj.lang.JoinPoint;

import java.util.HashSet;

public aspect BaseAspect {
  private static HashSet<String> affectedMethods;
  private static boolean baseRV = false;
  public static boolean inSet(JoinPoint.StaticPart contextJoinPoint) {
    if (baseRV) {
      return baseRV;
    }
    if (affectedMethods == null) {
      String impactedMethodsFilePath = System.getenv("IMPACTED_METHODS_FILE");
      System.out.println("impactedMethodsFilePath: " + impactedMethodsFilePath);
      if (impactedMethodsFilePath == null) {
        baseRV = true;
        return baseRV;
      }
      File impactedMethodsFile = new File(impactedMethodsFilePath);
      if (impactedMethodsFile.exists()) {
        try {
          FileInputStream fileInput = new FileInputStream(impactedMethodsFilePath);
          ObjectInputStream objectInput = new ObjectInputStream(fileInput);
          affectedMethods = (HashSet) objectInput.readObject();
        } catch (Exception ex) {
          ex.printStackTrace();
        }
        System.out.println("Affected methods (no signature): " + affectedMethods.size());
      } else {
        System.err.println("Impacted methods file does not exist!");
        affectedMethods = new HashSet<String>();
      }
    }
    return affectedMethods.contains(contextJoinPoint.getSignature().getDeclaringTypeName()
            + "#" + contextJoinPoint.getSignature().getName());
  }

  pointcut notwithin() :
  !within(sun..*) &&
  !within(java..*) &&
  !within(javax..*) &&
  !within(javafx..*) &&
  !within(com.sun..*) &&
  !within(org.dacapo.harness..*) &&
  !within(net.sf.cglib..*) &&
  !within(mop..*) &&
  !within(org.h2..*) &&
  !within(org.sqlite..*) &&
  !within(javamoprt..*) &&
  !within(rvmonitorrt..*) &&
  !within(org.junit..*) &&
  !within(junit..*) &&
  !within(java.lang.Object) &&
  !within(com.runtimeverification..*) &&
  !within(org.apache.maven.surefire..*) &&
  !within(org.mockito..*) &&
  !within(org.powermock..*) &&
  !within(org.easymock..*) &&
  !within(com.mockrunner..*) &&
  !within(org.jmock..*) &&
  if(inSet(thisEnclosingJoinPointStaticPart));
}
