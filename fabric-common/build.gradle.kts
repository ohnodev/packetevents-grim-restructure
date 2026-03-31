plugins {
    packetevents.`library-conventions`
}

repositories {
    maven("https://maven.fabricmc.net/")
    maven("https://repo.viaversion.com/")
}

dependencies {
    api(libs.bundles.adventure)
    api(project(":api"))
    api(project(":netty-common"))

    compileOnly(libs.netty)
    compileOnly(libs.fabric.loader)
    compileOnly(libs.slf4j.api)
    compileOnly(libs.via.version)
}

tasks.withType<JavaCompile> {
    options.release = 17
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}
